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
        <!-- Output accumulator values in message text -->
        <xsl:for-each select="//body/h1">
            <xsl:message>Before descendants of h1 #{position()}: {
                accumulator-before('word-count')
            }
            </xsl:message>
            <xsl:message>After descendants of h1 #{position()}: {
                accumulator-after('word-count')
            }
            </xsl:message>
        </xsl:for-each>
        <xsl:message>At end of html element: {
            /html/accumulator-after('word-count')
        }
        </xsl:message>

        <!-- Other code in this template... -->
    </xsl:template>

</xsl:stylesheet>