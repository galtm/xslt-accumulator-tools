<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:at="http://github.com/galtm/xslt-accumulator-tools"
    xmlns:genxsl="alias-for-xsl-Transform"
    xmlns:xspec-util="urn:x-xspec:compiler:base:util:compiler-eqname-utils:local"
    exclude-result-prefixes="#all"
    version="3.0">

    <!-- PARAMETERS -->
    <xsl:param name="at:acc-decl-uri" as="xs:string?"/>
    <xsl:param name="at:acc-name" as="xs:string?"/>
    <xsl:param name="at:acc-parent-uri" as="xs:string?"/>

    <xsl:param name="at:skip-whitespace" as="xs:boolean" select="true()"/>
    <xsl:param name="at:trunc" as="xs:integer" select="60"/>

    <!-- IMPORTS -->
    <xsl:import href="lib/xspec/src/compiler/base/util/compiler-eqname-utils.xsl"/>

    <!-- MODES -->
    <xsl:mode name="at:acc-view" use-accumulators="#all"/>

    <!-- ALIASES -->
    <xsl:namespace-alias stylesheet-prefix="genxsl" result-prefix="xsl"/>

    <xsl:template match="/" as="element()">
        <xsl:param name="acc-decl-uri" as="xs:string"
            select="(if ($at:acc-decl-uri != '')
            then $at:acc-decl-uri
            else processing-instruction(acc-decl-uri)/normalize-space())
            => resolve-uri(base-uri())"/>
        <xsl:param name="acc-name" as="xs:string"
            select="if ($at:acc-name != '')
            then $at:acc-name
            else processing-instruction(acc-name)/normalize-space()"/>
        <xsl:param name="acc-parent-uri" as="xs:string?"
            select="(if ($at:acc-parent-uri != '')
            then $at:acc-parent-uri
            else if (processing-instruction(acc-parent-uri)/normalize-space())
            then processing-instruction(acc-parent-uri)/normalize-space()
            else ())
            => resolve-uri(base-uri())"/>

        <xsl:call-template name="at:error-checking">
            <xsl:with-param name="acc-decl-uri" select="$acc-decl-uri"/>
            <xsl:with-param name="acc-name" select="$acc-name"/>
        </xsl:call-template>
        <xsl:variable name="transform-options" as="map(xs:string, item()*)">
            <xsl:call-template name="at:transform-options">
                <xsl:with-param name="acc-decl-uri" select="$acc-decl-uri"/>
                <xsl:with-param name="acc-name" select="$acc-name"/>
                <xsl:with-param name="acc-parent-uri" select="$acc-parent-uri"/>
                <xsl:with-param name="source" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="transform-result" select="transform($transform-options)"/>
        <xsl:sequence select="$transform-result?output"/>
    </xsl:template>

    <xsl:template name="at:transform-options" as="map(xs:string, item()*)">
        <xsl:param name="acc-decl-uri" as="xs:string"/>
        <xsl:param name="acc-name" as="xs:string"/>
        <xsl:param name="acc-parent-uri" as="xs:string?"/>
        <xsl:param name="source" as="document-node()"/>
        <xsl:variable name="combined-transform" as="element()">
            <genxsl:transform version="3.0" exclude-result-prefixes="#all">
                <genxsl:include href="acc-report-inclusion.xsl"/>
                <genxsl:import href="{($acc-parent-uri,$acc-decl-uri)[1]}"/>
            </genxsl:transform>
        </xsl:variable>
        <xsl:variable name="transform-options" as="map(xs:string, item()*)">
            <xsl:map>
                <xsl:map-entry key="'delivery-format'" select="'raw'"/>
                <xsl:map-entry key="'initial-mode'" select="xs:QName('at:acc-view')"/>
                <xsl:map-entry key="'source-node'" select="$source"/>
                <xsl:map-entry key="'stylesheet-node'" select="$combined-transform"/>
                <xsl:map-entry key="'stylesheet-params'">
                    <xsl:map>
                        <xsl:map-entry key="xs:QName('at:acc-decl-uri')"
                            select="$acc-decl-uri"/>
                        <xsl:map-entry key="xs:QName('at:acc-name')" select="$acc-name"/>
                        <xsl:map-entry key="xs:QName('at:skip-whitespace')"
                            select="$at:skip-whitespace"/>
                        <xsl:map-entry key="xs:QName('at:trunc')" select="$at:trunc"/>
                    </xsl:map>
                </xsl:map-entry>
            </xsl:map>
        </xsl:variable>
        <xsl:sequence select="$transform-options"/>
    </xsl:template>

    <xsl:template name="at:error-checking" as="empty-sequence()">
        <xsl:param name="acc-decl-uri" as="xs:string" required="yes"/>
        <xsl:param name="acc-name" as="xs:string" required="yes"/>
        <xsl:variable name="resolved-acc-name" as="xs:QName"
            select="if (matches($acc-name,'^Q\{'))
            then xspec-util:resolve-UQName($acc-name)
            else xs:QName($acc-name)"/>
        <xsl:if test="not(doc-available($acc-decl-uri))">
            <xsl:message terminate="yes" expand-text="1">Cannot find XSLT module {
                $acc-decl-uri}.</xsl:message>
        </xsl:if>
        <xsl:variable name="acc-decl" as="element(xsl:accumulator)*"
            select="doc($acc-decl-uri)//xsl:accumulator[
                resolve-QName(@name/string(), .) eq $resolved-acc-name
            ]"/>
        <xsl:choose>
            <xsl:when test="empty($acc-decl)">
                <xsl:message terminate="yes" expand-text="1">Cannot find accumulator named {
                    $acc-name} in XSLT module {$acc-decl-uri}.</xsl:message>
            </xsl:when>
            <xsl:when test="count($acc-decl) gt 1">
                <xsl:message terminate="yes" expand-text="1">Found multiple accumulators named {
                    $acc-name} in XSLT module {$acc-decl-uri}.</xsl:message>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- 
    This file is part of xslt-accumulator-tools.

    xslt-accumulator-tools is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    xslt-accumulator-tools is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License along with xslt-accumulator-tools. If not, see <https://www.gnu.org/licenses/>.
    -->

</xsl:stylesheet>