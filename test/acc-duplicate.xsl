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

    <!-- 
    This file is part of xslt-accumulator-tools.

    xslt-accumulator-tools is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    xslt-accumulator-tools is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License along with xslt-accumulator-tools. If not, see <https://www.gnu.org/licenses/>.
    -->

</xsl:stylesheet>