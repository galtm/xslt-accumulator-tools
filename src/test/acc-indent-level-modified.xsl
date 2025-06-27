<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:at="http://github.com/galtm/xslt-accumulator-tools"
    exclude-result-prefixes="#all"
    version="3.0">

    <xsl:mode use-accumulators="indent-level-modified"/>

    <xsl:accumulator name="indent-level-modified" as="xs:integer" initial-value="0">
        <xsl:accumulator-rule match="element() | text() | comment() | processing-instruction()[not(name(.)=('no-indent','add-ten'))]"
            select="$value + 1"/>
        <xsl:accumulator-rule match="element() | text() | comment() | processing-instruction()[not(name(.)=('no-indent','add-ten'))]"
            phase="end"
            select="$value - 1"/>

        <!-- Outlier rules, where the value is unchanged between the start and end visits,
            are needed for testing the at:second-column-non-element-node template -->
        <xsl:accumulator-rule match="processing-instruction(no-indent)" select="$value"/>
        <xsl:accumulator-rule match="processing-instruction(no-indent)" phase="end" select="$value"/>
        <xsl:accumulator-rule match="processing-instruction(add-ten)" select="$value + 10"/>
        <xsl:accumulator-rule match="processing-instruction(add-ten)" phase="end" select="$value"/>
    </xsl:accumulator>

</xsl:stylesheet>