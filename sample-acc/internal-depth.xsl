<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0">
    <xsl:mode use-accumulators="#all"/>
    <xsl:accumulator name="internal-depth" as="xs:integer" initial-value="0">
        <xsl:accumulator-rule phase="start"
            match="remark | *[@condition='future']">
            <!-- Start: Increment depth -->
            <xsl:sequence select="$value + 1"/>
        </xsl:accumulator-rule>
        <xsl:accumulator-rule phase="end"
            match="remark | *[@condition='future']">
            <!-- End: Decrement depth -->
            <xsl:sequence select="$value - 1"/>
        </xsl:accumulator-rule>
    </xsl:accumulator>
</xsl:stylesheet>