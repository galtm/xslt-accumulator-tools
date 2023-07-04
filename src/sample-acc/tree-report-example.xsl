<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns:at="http://github.com/galtm/xslt-accumulator-tools"
    exclude-result-prefixes="#all"
    version="3.0">

    <!-- This XSLT stylesheet illustrates how to augment
        an "end user" stylesheet with code to generate an
        accumulator report from a tree that this stylesheet
        defines in a variable. Look for "Part ... of 3"
        comments. -->

    <!-- ======================================================= -->
    <!-- Part 1 of 3: Use the $at:generate-tree-report static
        parameter to indicate whether to generate an accumulator
        report for a tree.

        NOTE: If you subsequently want to generate a report for an
        XML *file* based on an accumulator in this XSLT transform,
        the acc-reporter.xsl tool automatically switches this
        parameter to false during that tool's operation, to avoid
        interference. -->
    <xsl:param name="at:generate-tree-report" select="true()"
        as="xs:boolean" static="yes"/>

    <!-- Part 2 of 3: Import reporting code and provide values
        of the required global parameters. In <xsl:import>, use
        an href path that fits your directory arrangement. -->
    <xsl:import href="../acc-report-inclusion.xsl"
        use-when="$at:generate-tree-report"/>
    <xsl:param name="at:acc-name" select="'glossentry-position'"
        use-when="$at:generate-tree-report"/>
    <xsl:param name="at:acc-decl-uri" select="resolve-uri('glossary.xsl')"
        use-when="$at:generate-tree-report"/>
    <!-- ======================================================= -->

    <xsl:include href="glossary.xsl"/>

    <xsl:template match="/">
        <xsl:variable name="sorted-glossary-doc" as="document-node()">
            <xsl:document>
                <glossary xmlns="http://docbook.org/ns/docbook">
                    <xsl:perform-sort select="//db:glossentry">
                        <xsl:sort select="db:glossterm/normalize-space()"/>
                    </xsl:perform-sort>
                </glossary>                
            </xsl:document>
        </xsl:variable>
        <xsl:variable name="sorted-glossary-elem" as="element(db:glossary)"
            select="$sorted-glossary-doc/*"/>

        <!-- Output is the sorted glossary. -->
        <xsl:sequence select="$sorted-glossary-elem"/>

        <!-- ======================================================= -->
        <!-- Part 3 of 3. At a location where the tree variable is defined,
            change context to it and call at:process-root template.
            Here, we do this procedure (in the same way) for
            * A tree rooted at a document node($sorted-glossary-doc) and
            * A tree rooted at an element node ($sorted-glossary-elem).
            
            In your own code, use href values that suit your needs.
        -->
        <!-- If requested, generate tree-based accumulator reports. -->
        <xsl:result-document use-when="$at:generate-tree-report"
            href="{
                base-uri()
                => replace('\.xml$','-doc-tree-acc-report.html')
                => replace('/src/sample-acc/sample-xml/','/target/generated-resources/xml/xslt/')
            }">
            <xsl:for-each select="$sorted-glossary-doc">
                <xsl:call-template name="at:process-root"/>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document use-when="$at:generate-tree-report"
            href="{
            base-uri()
            => replace('\.xml$','-elem-tree-acc-report.html')
            => replace('/src/sample-acc/sample-xml/','/target/generated-resources/xml/xslt/')
            }">
            <xsl:for-each select="$sorted-glossary-elem">
                <xsl:call-template name="at:process-root"/>
            </xsl:for-each>
        </xsl:result-document>
        <!-- ======================================================= -->

    </xsl:template>

    <!--
    This file is part of xslt-accumulator-tools.

    xslt-accumulator-tools is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    xslt-accumulator-tools is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License along with xslt-accumulator-tools. If not, see <https://www.gnu.org/licenses/>.
    -->
</xsl:stylesheet>
