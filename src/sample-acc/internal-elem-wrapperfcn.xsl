<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0">

    <!-- Wrapper functions make accumulator functions available
        to an external transformation in XSpec -->
    <xsl:import href="../accumulator-test-tools.xsl"/>

    <xsl:mode use-accumulators="#all"/>
    <xsl:accumulator name="internal-elem" as="xs:string*"
        initial-value="()">
        <xsl:accumulator-rule phase="start"
            match="remark | *[@condition='future']">
            <!-- Start: Push element name on head of stack -->
            <xsl:sequence select="(name(.), $value)"/>
        </xsl:accumulator-rule>
        <xsl:accumulator-rule phase="end"
            match="remark | *[@condition='future']" >
            <!-- End: Pop first item from stack -->
            <xsl:sequence select="tail($value)"/>
        </xsl:accumulator-rule>
    </xsl:accumulator>

    <xsl:template match="remark">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>