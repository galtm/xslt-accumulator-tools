<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0">

    <xsl:include href="acc-decl-not-standalone.xsl"/>

    <xsl:template name="diagnostic-info" as="empty-sequence()">
        <xsl:if test="self::unicorn">
            <xsl:message>Found unicorn</xsl:message>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>