# XSLT Accumulator Tools

Utilities for exploring and testing XSLT accumulators, to complement an upcoming Balisage 2023 conference presentation.

- [Report of Accumulator Values](#report-of-accumulator-values)
- [Helper for XSpec Tests for Accumulators](#helper-for-xspec-tests-for-accumulators)

License: AGPL 3.0 or later

## Report of Accumulator Values
Use the `src/acc-reporter.xsl` stylesheet to generate an HTML report of accumulator values associated with nodes of an XML file.

Here is a [sample](https://htmlpreview.github.io/?https://github.com/galtm/xslt-accumulator-tools/blob/main/src/sample-acc/sample-xml/acc-report/word-count-sample-acc-report.html) that shows how the report looks.

### Required Inputs
The `src/acc-reporter.xsl` stylesheet requires the following information that you provide:

1. An XML file. Provide it as the source document for the transformation.

1. Information about your accumulator. Specify it through either XSLT global parameters or top-level processing instructions ([example](https://github.com/galtm/xslt-accumulator-tools/blob/6784904baeb7c4b45242020284a67ee2f7215e1b/sample-acc/sample-xml/section-with-elements.xml#L2-4)) in the XML source document, as the next table describes. (The parameter takes precedence over the processing instruction, if both appear.)


| Item | XSLT Parameter | Processing Instruction  |
|---|---|---|
| Accumulator name  | `$acc-name`  |  `<?acc-name my-accumulator-name?>` |
| URI of XSLT file containing accumulator declaration, relative to the XML file's base URI  | `$acc-decl-uri` | `<?acc-decl-uri my-accumulator-declaration-uri?>` |
| URI of top-level XSLT module, if different from the file containing the accumulator declaration, relative to the XML file's base URI | `$acc-toplevel-uri` | `<?acc-toplevel-uri my-main-xslt-uri?>`  |


In the notation above, the `at` prefix is associated with the `http://github.com/galtm/xslt-accumulator-tools` namespace.

If your accumulator's name is in a namespace with URI `foo`, you can use notation `Q{foo}my-accumulator-name` in the value of the `$acc-name` XSLT parameter or the `acc-name` processing instruction.

### Oxygen XML Editor Instructions

1. In Oxygen, load `xslt-accumulator-tools.xpr` and open the XML source document
1. Either add processing instructions as described above to the XML source document, or modify (a copy of) the "Accumulator Report" transformation scenario to populate the XSLT parameters 
1. Apply the "Accumulator Report" transformation scenario to the XML source document, which automatically opens the HTML report in your default browser 

### Command-Line Examples (Saxon)
**Prerequisite:** Install Saxon, referring to [Saxon documentation](https://saxonica.com/documentation12/index.html#!about/gettingstarted/gettingstartedjava) as needed.

From your clone of this repository, you can execute a command like the following:

`java -cp "...path to Saxon jar file..." net.sf.saxon.Transform -t -s:src/sample-acc/sample-xml/section-with-elements.xml -xsl:src/acc-reporter.xsl -o:section-with-elements-report.html`

The file `section-with-elements.xml` contains processing instructions that identify the relevant XSLT modules and the accumulator name, so the command above does not need to pass in any global parameter values. In the absence of those processing instructions, your command would have looked like this:

`java -cp "...path to Saxon jar file..." net.sf.saxon.Transform -t -s:src/sample-acc/sample-xml/section-with-elements.xml -xsl:src/acc-reporter.xsl -o:section-with-elements-report.html acc-name=Q{my-acc-ns}element-count acc-decl-uri=../acc-decl-not-standalone.xsl acc-toplevel-uri=../parent.xsl`

### Variation: Generating Report Based on Tree Not in XML File
You can generate an HTML report of accumulator values associated with nodes of a tree that your XSLT stylesheet defines in a variable, even if the tree is not saved to an XML file. In this situation, you do the following:

1. Augment your XSLT stylesheet to supply data that the report generation code needs and to invoke it from a location of your code where the tree variable is in scope.
1. Run your XSLT transformation.

For an example that illustrates step 1, see this set of files:
```
src/sample-acc/tree-report-example.xsl
src/sample-acc/glossary.xsl
src/sample-acc/sample-xml/glossary.xml
```

If you generate an *XML-file-based* report for `glossary.xml`, you can see that the report shows glossary terms in the same sequence as in this XML file.

If you generate a *tree-based* report by transforming the sample source document `glossary.xml` with the stylesheet `tree-report-example.xsl`, you can see that the reports show glossary terms in alphabetical order. That is because the `tree-report-example.xsl` stylesheet creates a tree in an XSLT variable by sorting the glossary terms from the XML source file.

`java -cp "...path to Saxon jar file..." net.sf.saxon.Transform -t -s:src/sample-acc/sample-xml/glossary.xml -xsl:src/sample-acc/tree-report-example.xsl`

## Helper for XSpec Tests for Accumulators
Import the `src/accumulator-test-tools.xsl` file in an XSLT stylesheet that you want to test with XSpec via `run-as="external"`. An example of this test architecture is in the following file:
```
src/sample-acc/test/internal-elem-external.xspec
```

For examples of architectures that test accumulators using `run-as="import"` (default), see these files:
```
src/sample-acc/test/internal-elem-dedicated.xspec
src/sample-acc/test/internal-elem-integrated.xspec
```
