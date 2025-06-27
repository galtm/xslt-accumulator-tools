<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:at="http://github.com/galtm/xslt-accumulator-tools"
    xmlns:dup="http://github.com/galtm/xslt-accumulator-tools"
    exclude-result-prefixes="#all"
    version="3.0">

    <xsl:mode use-accumulators="#all"/>

    <xsl:accumulator name="at:acc" as="xs:integer" initial-value="0">
        <xsl:accumulator-rule match="*" select="$value + 1"/>
    </xsl:accumulator>

    <!-- ERROR (intentional for testing purposes): Multiple accumulators with
        the same name and same import precedence -->
    <xsl:accumulator name="dup:acc" as="xs:integer" initial-value="0">
        <xsl:accumulator-rule match="*" select="$value + 1"/>
    </xsl:accumulator>

    <xsl:accumulator name="at:acc2" as="xs:integer" initial-value="0">
        <xsl:accumulator-rule match="*" select="$value + 1"/>
    </xsl:accumulator>

</xsl:stylesheet>