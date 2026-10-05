<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all"
    version="3.0">

    <!-- Wrapper functions make accumulator functions available
        to an external transformation in XSpec -->
    <xsl:import href="../accumulator-test-tools.xsl"/>

    <!-- System under test -->
    <xsl:include href="internal-elem.xsl"/>

</xsl:stylesheet>