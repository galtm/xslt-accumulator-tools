<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0">

    <!-- This example shows how to use acc-reporter.xsl when an accumulator declaration
        is in an XSLT file that is not the top-level module. In this case, the "diagnostic-info"
        template is defined in parent.xsl. In the sample XML file, section-with-elements.xsl,
        processing instructions provide paths to both this file and parent.xsl. 
    -->

    <xsl:mode use-accumulators="#all"/>

    <xsl:accumulator name="h:node-count" xmlns:h="my-acc-ns"
        as="xs:integer" initial-value="0">
        <xsl:accumulator-rule match="*">
            <xsl:call-template name="diagnostic-info"/>
            <xsl:sequence select="$value+1"/>
        </xsl:accumulator-rule>
    </xsl:accumulator>
    
</xsl:stylesheet>