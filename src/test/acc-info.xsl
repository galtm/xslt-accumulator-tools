<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:at="http://github.com/galtm/xslt-accumulator-tools"
    exclude-result-prefixes="#all"
    version="3.0">

    <xsl:import href="../accumulator-test-tools.xsl"/>

    <xsl:mode use-accumulators="node-reached"/>

    <!-- Store information about the accumulator phase and node type,
        for testing purposes. -->
    <xsl:accumulator name="node-reached"
        as="map(xs:string, xs:string)"
        initial-value="map{'phase': 'initial-value'}">
        <xsl:accumulator-rule match="node() | document-node()" phase="start">
            <xsl:map>
                <xsl:map-entry key="'phase'" select="'start'"/>
                <xsl:map-entry key="'node-type'">
                    <xsl:call-template name="node-type"/>
                </xsl:map-entry>
            </xsl:map>
        </xsl:accumulator-rule>
        <xsl:accumulator-rule match="node() | document-node()" phase="end">
            <xsl:map>
                <xsl:map-entry key="'phase'" select="'end'"/>
                <xsl:map-entry key="'node-type'">
                    <xsl:call-template name="node-type"/>
                </xsl:map-entry>
            </xsl:map>
        </xsl:accumulator-rule>
    </xsl:accumulator>
    
    <xsl:template name="node-type" as="xs:string">
        <xsl:context-item use="required"/>
        <xsl:choose>
            <xsl:when test=". instance of element()">element</xsl:when>
            <xsl:when test=". instance of text()">text</xsl:when>
            <xsl:when test=". instance of comment()">comment</xsl:when>
            <xsl:when test=". instance of processing-instruction()">PI</xsl:when>
            <xsl:when test=". instance of document-node()">document-node</xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>