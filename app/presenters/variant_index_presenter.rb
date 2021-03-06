class VariantIndexPresenter
  attr_reader :variant

  def initialize(variant)
    @variant = variant
  end

  def as_json(opts = {})
    {
      id: variant.id,
      entrez_name: variant.gene.name,
      gene_id: variant.gene.id,
      entrez_id: variant.gene.entrez_id,
      name: variant.name,
      description: variant.description,
      type: :variant,
      variant_types: variant.variant_types.map { |vt| VariantTypePresenter.new(vt) },
      evidence_items: EvidenceItemsByStatusPresenter.new(variant),
      coordinates: {
        chromosome: variant.chromosome,
        start: variant.start,
        stop: variant.stop,
        reference_bases: variant.reference_bases,
        variant_bases: variant.variant_bases,
        representative_transcript: variant.representative_transcript,
        chromosome2: variant.chromosome2,
        start2: variant.start2,
        stop2: variant.stop2,
        representative_transcript2: variant.representative_transcript2,
        ensembl_version: variant.ensembl_version,
        reference_build: variant.reference_build
      }
    }
  end
end
