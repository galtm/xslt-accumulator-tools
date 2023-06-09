<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    <xsl:mode use-accumulators="#all"/>
    <xsl:accumulator name="heading-depth" as="xs:integer" initial-value="0">
        <xsl:accumulator-rule match="h1" select="1"/>
        <xsl:accumulator-rule match="h2" select="2"/>
        <xsl:accumulator-rule match="h3" select="3"/>
    </xsl:accumulator>
</xsl:stylesheet>