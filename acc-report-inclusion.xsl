<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:at="http://github.com/galtm/xslt-accumulator-tools"
    xmlns:xspec-util="urn:x-xspec:compiler:base:util:compiler-eqname-utils:local"
    exclude-result-prefixes="#all"
    version="3.0">

    <!-- ========== -->
    <!-- PARAMETERS -->
    <xsl:param name="at:acc-decl-uri" as="xs:string" required="yes"/>
    <xsl:param name="at:acc-name" as="xs:string" required="yes"/>
    <xsl:param name="at:skip-whitespace" as="xs:boolean" select="true()"/>
    <xsl:param name="at:trunc" as="xs:integer" select="60"/>

    <!-- ======= -->
    <!-- IMPORTS -->
    <xsl:import href="lib/xspec/src/compiler/base/util/compiler-eqname-utils.xsl"/>

    <!-- ===== -->
    <!-- MODES -->
    <xsl:mode name="at:acc-view" use-accumulators="#all" streamable="no"/>

    <!-- ============ -->
    <!-- ACCUMULATORS -->

    <xsl:accumulator name="at:indent-level" as="xs:integer" initial-value="0">
        <xsl:accumulator-rule match="element() | text() | comment() | processing-instruction()"
            select="$value + 1"/>
        <xsl:accumulator-rule match="element() | text() | comment() | processing-instruction()"
            phase="end"
            select="$value - 1"/>
    </xsl:accumulator>

    <!-- The at:two-value-queue accumulator stores another accumulator's
        last value and current value. -->
    <xsl:accumulator name="at:two-value-queue" initial-value="()" as="map(*)?">
        <xsl:accumulator-rule match="element() | text() | comment() | processing-instruction() | document-node()"
            phase="start">
            <xsl:map>
                <xsl:map-entry key="'prior'" select="if (exists($value)) then $value('current') else ()"/>
                <xsl:map-entry key="'current'" select="accumulator-before($at:acc-name)"/>
            </xsl:map>
        </xsl:accumulator-rule>
        <xsl:accumulator-rule match="element() | text() | comment() | processing-instruction() | document-node()"
            phase="end">
            <xsl:map>
                <xsl:map-entry key="'prior'" select="$value('current')"/>
                <xsl:map-entry key="'current'" select="accumulator-after($at:acc-name)"/>
            </xsl:map>
        </xsl:accumulator-rule>
    </xsl:accumulator>

    <xsl:accumulator name="at:prior-value" initial-value="()">
        <xsl:accumulator-rule match="element() | text() | comment() | processing-instruction() | document-node()">
            <xsl:sequence select="(accumulator-before('at:two-value-queue'))('prior')"/>
        </xsl:accumulator-rule>
        <xsl:accumulator-rule match="element() | text() | comment() | processing-instruction() | document-node()"
            phase="end">
            <xsl:sequence select="(accumulator-after('at:two-value-queue'))('prior')"/>
        </xsl:accumulator-rule>
    </xsl:accumulator>

    <!-- ======================= -->
    <!-- TEMPLATES AND FUNCTIONS -->

    <xsl:template name="at:process-root" as="element(h:html)" expand-text="1">
        <!-- Context item is document node or other root of tree -->
        <xsl:context-item as="node()" use="required"/>

        <xsl:variable name="at:doc-file-name" as="xs:string"
            select="replace(base-uri(),'^.*/','')"/>
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>Values of {$at:acc-name} Accumulator for Tree in {$at:doc-file-name}</title>
                <style type="text/css">{
                    unparsed-text-lines('acc-report.css') => string-join('&#10;')
                }</style>
            </head>
            <body>
                <h1>Values of {$at:acc-name} Accumulator for Tree in {$at:doc-file-name}</h1>
                <p>Document URI: <code>{base-uri(.) => at:truncate-uri()}</code></p>
                <p>Accumulator declaration URI: <code>{$at:acc-decl-uri => at:truncate-uri()}</code></p>
                <xsl:call-template name="at:show-declaration"/>
                <table>
                    <thead>
                        <th>Node or Element Tag</th>
                        <th>Value, Changed or Document Start/End</th>
                    </thead>
                    <tbody>
                        <xsl:apply-templates select="." mode="at:acc-view"/>
                    </tbody>
                </table>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="document-node()" mode="at:acc-view" as="element(h:tr)+">
        <tr>
            <td>
                <em>Document node start</em>
            </td>
            <td>
                <xsl:variable name="current-before" select="accumulator-before($at:acc-name)"/>
                <xsl:call-template name="at:acc-value-if-changed">
                    <xsl:with-param name="acc-value" select="$current-before"/>
                    <xsl:with-param name="acc-prior-value" select="if (empty($current-before)) then 1 else ()"/>
                </xsl:call-template>
            </td>
        </tr>
        <xsl:apply-templates mode="#current"/>
        <tr>
            <td>
                <em>Document node end</em>
            </td>
            <td>
                <xsl:variable name="current-after" select="accumulator-after($at:acc-name)"/>
                <xsl:call-template name="at:acc-value-if-changed">
                    <xsl:with-param name="acc-value" select="$current-after"/>
                    <xsl:with-param name="acc-prior-value" select="if (empty($current-after)) then 1 else ()"/>
                </xsl:call-template>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="element()" mode="at:acc-view" expand-text="1"
        as="element(h:tr)+">
        <tr>
            <td>
                <xsl:call-template name="at:indent"/>
                <span class='tag'>{'&lt;' || name(.)}</span>
                <xsl:sequence select="at:list-attrs(@*)"/>
                <span class="tag">{'>'}</span>
            </td>
            <td>
                <xsl:call-template name="at:acc-value-if-changed"/>
            </td>
        </tr>
        <xsl:apply-templates mode="#current"/>
        <tr>
            <td>
                <xsl:call-template name="at:indent"/>
                <span class='tag'>{'&lt;/' || name(.) || '>'}</span>
            </td>
            <td>
                <!-- At end tag, use accumulator-after instead of accumulator-before -->
                <xsl:call-template name="at:acc-value-if-changed">
                    <xsl:with-param name="acc-value" select="accumulator-after($at:acc-name)"/>
                    <xsl:with-param name="acc-prior-value" select="accumulator-after('at:prior-value')"/>
                </xsl:call-template>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="text()" mode="at:acc-view" as="element(h:tr)?">
        <xsl:if test="not($at:skip-whitespace) or
            string-length(replace(.,'\s+','')) gt 0">
            <tr>
                <td>
                    <xsl:call-template name="at:truncated-text-or-comment"/>
                </td>
                <td>
                    <xsl:call-template name="at:second-column-non-element-node"/>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template match="comment()" mode="at:acc-view" as="element(h:tr)?">
        <tr>
            <td>
                <span class="comment">
                    <xsl:call-template name="at:truncated-text-or-comment"/>
                </span>
            </td>
            <td>
                <xsl:call-template name="at:second-column-non-element-node"/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="processing-instruction()" mode="at:acc-view"
        expand-text="1" as="element(h:tr)?">
        <xsl:if test="not(name(.)=('acc-decl-uri','acc-name','acc-parent-uri'))">
            <tr>
                <td>
                    <span class="pi">
                        <xsl:variable name="stringseq" as="xs:string+">
                            <xsl:call-template name="at:indent"/>
                            <xsl:sequence select="'&lt;?' || name(.) || ' ' || . || '?>'"/>                            
                        </xsl:variable>
                        <xsl:sequence select="string-join($stringseq,'')"/>
                    </span>
                </td>
                <td>
                    <xsl:call-template name="at:second-column-non-element-node"/>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template name="at:indent" as="xs:string">
        <xsl:context-item use="required" as="node()"/>
        <xsl:variable name="level" as="xs:integer"
            select="accumulator-before('at:indent-level')"/>
        <xsl:variable name="width" as="xs:integer" select="2"/>
        <xsl:sequence select="string-join(
            for $j in (1 to $level*$width) return '&#160;',
            '')"/>
    </xsl:template>

    <!-- For non-element nodes, first column doesn't render distinct start and
        end phases. Make the second column distinguish phases only if the
        accumulator has different values for this node at start and end phases
        (which is probably uncommon in practice, for a non-element node). -->
    <xsl:template name="at:second-column-non-element-node">
        <xsl:context-item use="required"/>
        <xsl:variable name="start-phase-info" as="element(h:pre)?">
            <xsl:call-template name="at:acc-value-if-changed"/>
        </xsl:variable>
        <xsl:variable name="end-phase-info" as="element(h:pre)?">
            <xsl:call-template name="at:acc-value-if-changed">
                <xsl:with-param name="acc-value" select="accumulator-after($at:acc-name)"/>
                <xsl:with-param name="acc-prior-value" select="accumulator-after('at:prior-value')"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="empty($end-phase-info)">
                <!-- Empty $end-phase-info means the accumulator has the same value
                    at the node's start and end phases (because the at:acc-value-if-changed
                    template compares the same node's start and end phase values).
                    In this case, suppress "Start:" label and show accumulator value once.
                    Output data type in this case is element(h:pre). -->
                <xsl:sequence select="$start-phase-info"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Output is span, pre, span, pre -->
                <span>Start: </span><xsl:sequence select="$start-phase-info"/>
                <span>End: </span><xsl:sequence select="$end-phase-info"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="at:show-declaration" as="element(h:details)">
        <xsl:param name="acc-decl-uri" as="xs:string" select="$at:acc-decl-uri"/>
        <xsl:param name="acc-name" as="xs:string" select="$at:acc-name"/>
        <details>
            <summary>Declaration</summary>
            <xsl:variable name="resolved-acc-name" as="xs:QName"
                select="if (matches($acc-name, '^Q\{'))
                then xspec-util:resolve-UQName($acc-name)
                else QName('', $acc-name)"/>
            <xsl:variable name="acc-decl" as="element(xsl:accumulator)"
                select="doc($acc-decl-uri)//xsl:accumulator[
                resolve-QName(@name/string(), .) eq $resolved-acc-name
                ]"/>
            <pre><xsl:sequence select="serialize($acc-decl, map{'indent': true()})"/></pre>
        </details>
    </xsl:template>

    <xsl:template name="at:truncated-text-or-comment" as="xs:string">
        <xsl:context-item use="required" as="node()"/>
        <xsl:variable name="stringseq" as="xs:string+">
            <xsl:call-template name="at:indent"/>
            <xsl:if test="self::comment()">
                <xsl:sequence select="'&lt;!--'"/>
            </xsl:if>
            <xsl:sequence select="substring(.,1,$at:trunc)"/>
            <xsl:if test="string-length(.) gt $at:trunc">
                <xsl:sequence select="'...'"/>
            </xsl:if>
            <xsl:if test="self::comment()">
                <xsl:sequence select="'--&gt;'"/>
            </xsl:if>
        </xsl:variable>
        <xsl:sequence select="string-join($stringseq,'')"/>
    </xsl:template>

    <xsl:template name="at:acc-value-if-changed" as="element(h:pre)?">
        <xsl:param name="acc-value" select="accumulator-before($at:acc-name)"/>
        <xsl:param name="acc-prior-value" select="accumulator-before('at:prior-value')"/>
        <xsl:if test="not(deep-equal($acc-prior-value, $acc-value))">
            <pre>
                <xsl:sequence select="if (empty($acc-value))
                    then '()'
                    else serialize(
                        $acc-value,
                        map {
                        'indent': true(),
                        'method': 'adaptive'
                        }
                    )"/>
            </pre>
        </xsl:if>
    </xsl:template>

    <xsl:function name="at:list-attrs" as="element(h:span)*">
        <xsl:param name="attrs" as="attribute()*"/>
        <xsl:iterate select="$attrs" expand-text="1">
            <span class="attrname">{' ' || name(.) || '='}</span>
            <span class="attrval">{'"' || . || '"'}</span>
        </xsl:iterate>
    </xsl:function>

    <xsl:function name="at:truncate-uri" as="xs:string">
        <xsl:param name="uri" as="xs:string?"/>
        <xsl:variable name="repo-sample-acc" as="xs:string"
            select="'xslt-accumulator-tools/sample-acc'"/>
        <xsl:sequence select="replace($uri,'^.*' || $repo-sample-acc,
            '.../' || $repo-sample-acc)"/>
    </xsl:function>

    <!--
    This file is part of xslt-accumulator-tools.

    xslt-accumulator-tools is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    xslt-accumulator-tools is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License along with xslt-accumulator-tools. If not, see <https://www.gnu.org/licenses/>.
    -->

</xsl:stylesheet>