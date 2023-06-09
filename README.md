# XSLT Accumulator Tools

Utilities for exploring and testing XSLT accumulators, to complement an upcoming Balisage 2023 conference presentation.

License: AGPL 3.0 or later

## Report of Accumulator Values
Use the `acc-reporter.xsl` stylesheet to generate an HTML report of accumulator values associated with nodes of an XML file. This stylesheet requires the following information that you provide: 

1. An XML file. Provide it as the source document for the transformation.

1. Information about your accumulator. Specify it through either XSLT global parameters or top-level processing instructions in the XML source document, as the next table describes. (The parameter takes precedence over the processing instruction, if both appear.)


| Item | XSLT Parameter | Processing Instruction  |
|---|---|---|
| Accumulator name  | `$at:acc-name`  |  `<?acc-name my-accumulator-name?>` |
| URI of XSLT file containing accumulator declaration, relative to the XML file's base URI  | `$at:acc-decl-uri` | `<?acc-decl-uri my-accumulator-declaration-uri?>` |
| URI of top-level XSLT module, if different from the file containing the accumulator declaration, relative to the XML file's base URI | `$at:acc-parent-uri` | `<?acc-parent-uri my-main-xslt-uri?>`  |


In the notation above, the `at` prefix is associated with the `http://github.com/galtm/xslt-accumulator-tools` namespace.

If your accumulator's name is in a namespace with URI `foo`, you can use notation `Q{foo}my-accumulator-name` in the value of the `$at:acc-name` XSLT parameter or the `acc-name` processing instruction.

### Oxygen XML Editor Instructions

1. In Oxygen, load `xslt-accumulator-tools.xpr` and open the XML source document
1. Either add processing instructions as described above to the XML source document, or modify (a copy of) the "Accumulator Report" transformation scenario to populate the XSLT parameters 
1. Apply the "Accumulator Report" transformation scenario to the XML source document, which automatically opens the HTML report in your default browser 

### Command-Line Examples (Saxon)
**Prerequisite:** Install Saxon, referring to [Saxon documentation](https://saxonica.com/documentation12/index.html#!about/gettingstarted/gettingstartedjava) as needed.

From your clone of this repository, you can execute a command like the following:

`java -cp "...path to Saxon jar file..." net.sf.saxon.Transform -t -s:sample-acc/sample-xml/section-with-elements.xml -xsl:acc-reporter.xsl -o:section-with-elements-report.html`

The file `section-with-elements.xml` contains processing instructions that identify the relevant XSLT modules and the accumulator name, so the command above does not need to pass in any global parameter values. In the absence of those processing instructions, your command would have looked like

`java -cp "...path to Saxon jar file..." net.sf.saxon.Transform -t -s:sample-acc/sample-xml/section-with-elements.xml -xsl:acc-reporter.xsl -o:section-with-elements-report.html acc-name=node-count acc-decl-uri=../acc-decl-not-standalone.xsl acc-parent-uri=../parent.xsl`

or, specifying the namespace of the global parameter in case of a conflict with globals in your own XSLT code,

`java -cp "...path to Saxon jar file..." net.sf.saxon.Transform -t -s:sample-acc/sample-xml/section-with-elements.xml -xsl:acc-reporter.xsl -o:section-with-elements-report.html {http://github.com/galtm/xslt-accumulator-tools}acc-name=node-count {http://github.com/galtm/xslt-accumulator-tools}acc-decl-uri=../acc-decl-not-standalone.xsl {http://github.com/galtm/xslt-accumulator-tools}acc-parent-uri=../parent.xsl` 


## Helper for XSpec Tests for Accumulators
Import the `accumulator-test-tools.xsl` file in an XSLT stylesheet that you want to test with XSpec via `run-as="external"`. An example of this test architecture is in the following file:
```
sample-acc/test/internal-elem-external.xspec
```

For examples of architectures that test accumulators using `run-as="import"` (default), see
```
sample-acc/test/internal-elem-dedicated.xspec
sample-acc/test/internal-elem-integrated.xspec
```
