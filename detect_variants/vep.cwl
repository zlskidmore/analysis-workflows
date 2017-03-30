#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Ensembl Variant Effect Predictor"
baseCommand: ["/usr/bin/perl", "/usr/bin/variant_effect_predictor.pl"]
requirements:
    - class: ShellCommandRequirement
    - class: InlineJavascriptRequirement
    - class: ResourceRequirement
      ramMin: 32000
      tmpdirMin: 25000
arguments:
    ["--format", "vcf",
    "--vcf",
    "--plugin", "Downstream",
    "--plugin", "Wildtype",
    "--symbol",
    "--term", "SO",
    "--flag_pick",
    "-o", { valueFrom: $(runtime.outdir)/annotated.vcf },
    "--dir",
    { valueFrom: "`", shellQuote: false },
    { valueFrom: "cat", shellQuote: false },
    { valueFrom: $(inputs.cache_dir), shellQuote: false },
    { valueFrom: "`", shellQuote: false }]
inputs:
    vcf:
        type: File
        inputBinding:
            prefix: "-i"
            position: 1
    cache_dir:
        type: File
    synonyms_file:
        type: File?
        inputBinding:
            prefix: "--synonyms"
            position: 2
    coding_only:
        type: boolean
        inputBinding:
            prefix: "--coding_only"
            position: 3
        default: false
    local_cache:
        type: boolean
        inputBinding:
            valueFrom: |
                ${
                    if (inputs.local_cache) {
                        return ["--offline", "--cache", "--maf_exac"]
                    }
                    else {
                        return "--database"
                    }
                }
            position: 4
        default: true
outputs:
    annotated_vcf:
        type: File
        outputBinding:
            glob: "annotated.vcf"
    vep_summary:
        type: File
        outputBinding:
            glob: "annotated.vcf_summary.html"
