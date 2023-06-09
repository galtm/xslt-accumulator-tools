<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0">
    <xsl:mode use-accumulators="#all"/>
    <xsl:accumulator name="word-count"
        as="xs:integer"
        initial-value="0">
        <xsl:accumulator-rule match="text()"
            select="$value + count(tokenize(.))"/>
    </xsl:accumulator>

    <xsl:template match="/" expand-text="1">
        <!-- Output accumulator values as text -->
        <xsl:for-each select="//body/h1">
            <p>Before descendants of h1 #{position()}: {accumulator-before('word-count')}</p>
            <p>After descendants of h1 #{position()}: {accumulator-after('word-count')}</p>
        </xsl:for-each>
        <p>At end of html element: {/html/accumulator-after('word-count')}</p>

        <!-- Other code in this template... -->
    </xsl:template>

</xsl:stylesheet>