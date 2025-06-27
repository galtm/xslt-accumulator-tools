<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:at="http://github.com/galtm/xslt-accumulator-tools"
    xmlns:genxsl="alias-for-xsl-Transform"
    xmlns:xspec-util="urn:x-xspec:compiler:base:util:compiler-eqname-utils:local"
    exclude-result-prefixes="#all"
    version="3.0">

    <!-- ========== -->
    <!-- PARAMETERS -->
    <xsl:param name="acc-decl-uri" as="xs:string?"/>
    <xsl:param name="acc-name" as="xs:string?"/>
    <xsl:param name="acc-toplevel-uri" as="xs:string?"/>

    <xsl:param name="at:skip-whitespace" as="xs:boolean" select="true()"/>
    <xsl:param name="at:trunc" as="xs:integer" select="60"/>

    <!-- ======= -->
    <!-- IMPORTS -->
    <xsl:import href="lib/xspec/src/compiler/base/util/compiler-eqname-utils.xsl"/>

    <!-- ======= -->
    <!-- ALIASES -->
    <xsl:namespace-alias stylesheet-prefix="genxsl" result-prefix="xsl"/>

    <!-- ========= -->
    <!-- TEMPLATES -->

    <!--
        This template transforms the given XML file with a generated
        XSLT stylesheet that combines tools from this repository
        with user-specified XSLT code.

        Parameters:

        $acc-decl-uri-local: URI of file containing accumulator
            declaration. Default is from global $acc-decl-uri, if
            nonempty, or the XML tree's top-level processing
            instruction named acc-decl-uri. If used, the default
            value is resolved relative to the XML file's base URI.
        $acc-name-local: Accumulator name. Default is from global
            $acc-name, if nonempty, or the XML tree's top-level
            processing instruction named acc-name.
        $acc-toplevel-uri-local: URI of top-level XSLT file, if
            different from the file containing the accumulator
            declaration. Default is from global $acc-toplevel-uri,
            if nonempty, or the XML tree's top-level processing
            instruction named acc-toplevel-uri. If used, the
            default value is resolved relative to the XML file's
            base URI.
    -->
    <xsl:template match="/" as="element()">
        <xsl:param name="acc-decl-uri-local" as="xs:string"
            select="(if ($acc-decl-uri != '')
            then $acc-decl-uri
            else processing-instruction('acc-decl-uri')/normalize-space())
            => resolve-uri(base-uri())"/>
        <xsl:param name="acc-name-local" as="xs:string"
            select="if ($acc-name != '')
            then $acc-name
            else processing-instruction('acc-name')/normalize-space()"/>
        <xsl:param name="acc-toplevel-uri-local" as="xs:string?"
            select="(if ($acc-toplevel-uri != '')
            then $acc-toplevel-uri
            else if (processing-instruction('acc-toplevel-uri')/normalize-space())
            then processing-instruction('acc-toplevel-uri')/normalize-space()
            else ())
            => resolve-uri(base-uri())"/>

        <xsl:call-template name="at:error-checking">
            <xsl:with-param name="acc-decl-uri" select="$acc-decl-uri-local"/>
            <xsl:with-param name="acc-name" select="$acc-name-local"/>
        </xsl:call-template>
        <xsl:variable name="transform-options" as="map(xs:string, item()*)">
            <xsl:call-template name="at:transform-options">
                <xsl:with-param name="acc-decl-uri" select="$acc-decl-uri-local"/>
                <xsl:with-param name="acc-name" select="$acc-name-local"/>
                <xsl:with-param name="acc-toplevel-uri" select="$acc-toplevel-uri-local"/>
                <xsl:with-param name="source" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="transform-result" select="transform($transform-options)"/>
        <xsl:sequence select="$transform-result?output"/>
    </xsl:template>

    <!--
        This template creates a map of transform options suitable for
        use with transform().

        Parameters:

        $acc-decl-uri: Like top-level template's $acc-decl-uri-local
        $acc-name: Like top-level template's $acc-name-local
        $acc-toplevel-uri: Like top-level template's $acc-toplevel-uri-local
        $source: XML document node
    -->
    <xsl:template name="at:transform-options" as="map(xs:string, item()*)">
        <xsl:param name="acc-decl-uri" as="xs:string"/>
        <xsl:param name="acc-name" as="xs:string"/>
        <xsl:param name="acc-toplevel-uri" as="xs:string?"/>
        <xsl:param name="source" as="document-node()"/>
        <xsl:variable name="combined-transform" as="element()">
            <genxsl:transform version="3.0" exclude-result-prefixes="#all">
                <!-- Disable tree-based report generation to prevent
                    acc-report-inclusion.xsl from being included twice. -->
                <genxsl:param name="at:generate-tree-report" select="false()"
                    as="xs:boolean" static="yes">
                    <xsl:namespace name="at" select="'http://github.com/galtm/xslt-accumulator-tools'"/>
                    <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
                </genxsl:param>
                <genxsl:include href="acc-report-inclusion.xsl"/>
                <genxsl:import href="{($acc-toplevel-uri,$acc-decl-uri)[1]}"/>
            </genxsl:transform>
        </xsl:variable>
        <xsl:variable name="transform-options" as="map(xs:string, item()*)">
            <xsl:map>
                <xsl:map-entry key="'delivery-format'" select="'raw'"/>
                <xsl:map-entry key="'initial-template'" select="xs:QName('at:process-root')"/>
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

    <!--
        This template checks that the user-specified XSLT module
        has exactly one accumulator by the expected name.

        Parameters:

        $acc-decl-uri: Like top-level template's $acc-decl-uri-local
        $acc-name: Like top-level template's $acc-name-local
    -->
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

</xsl:stylesheet>