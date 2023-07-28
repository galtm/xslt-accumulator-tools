<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:at="http://github.com/galtm/xslt-accumulator-tools"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="#all"
    version="3.0">

    <!-- Wrap fn:accumulator-before and fn:accumulator-after
        so they can be accessed from an XSpec external transformation
        using x:call. -->

    <!--
        This function is a wrapper around fn:accumulator-before.

        Parameters:

        $context: Context node from which to call fn:accumulator-before
        $name: Accumulator name
    -->
    <xsl:function name="at:accumulator-before" visibility="public">
        <xsl:param name="context" as="node()?"/>
        <xsl:param name="name" as="xs:string"/>
        <!-- If data type of $context is "node()" then XSpec with run-as="import"
            cannot catch an empty context. So, allow "node?" and check for the
            empty case here. -->
        <xsl:if test="empty($context)">
            <xsl:sequence select="error(xs:QName('at:XPTY0004'),
                'An empty sequence is not allowed as the context of accumulator-before()')"/>
        </xsl:if>
        <xsl:sequence select="$context/fn:accumulator-before($name)"/>
    </xsl:function>

    <!--
        This function is a wrapper around fn:accumulator-after.

        Parameters:

        $context: Context node from which to call fn:accumulator-after
        $name: Accumulator name
    -->
    <xsl:function name="at:accumulator-after" visibility="public">
        <xsl:param name="context" as="node()?"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:if test="empty($context)">
            <xsl:sequence select="error(xs:QName('at:XPTY0004'),
                'An empty sequence is not allowed as the context of accumulator-after()')"/>
        </xsl:if>
        <xsl:sequence select="$context/fn:accumulator-after($name)"/>
    </xsl:function>

    <!-- 
    This file is part of xslt-accumulator-tools.

    xslt-accumulator-tools is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    xslt-accumulator-tools is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License along with xslt-accumulator-tools. If not, see <https://www.gnu.org/licenses/>.
    -->
</xsl:transform>