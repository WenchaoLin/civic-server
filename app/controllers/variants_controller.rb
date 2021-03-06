class VariantsController < ApplicationController
  include WithComment
  include WithSoftDeletion

  actions_without_auth :index, :show, :typeahead_results, :datatable, :gene_index, :entrez_gene_index, :variant_group_index
  skip_analytics :typeahead_results,

  def index
    variants = Variant.index_scope
      .joins(:evidence_items)
      .order('variants.id asc')
      .page(params[:page].to_i)
      .per(params[:count].to_i)
      .uniq

    render json: PaginatedCollectionPresenter.new(
      variants,
      request,
      VariantIndexPresenter,
      PaginationPresenter
    )
  end

  def gene_index
    variant_gene_index(:gene_id, :id)
  end

  def entrez_gene_index
    variant_gene_index(:entrez_id, :entrez_id)
  end

  def variant_group_index
    variants = Variant.index_scope
      .order('variants.id asc')
      .page(params[:page].to_i)
      .per(params[:count].to_i)
      .joins(:variant_groups)
      .where(variant_groups: { id: params[:variant_id] })
      .uniq

    render json: PaginatedCollectionPresenter.new(
      variants,
      request,
      VariantIndexPresenter,
      PaginationPresenter
    )
  end

  def show
    variant = Variant.view_scope.find_by!(id: params[:id])
    render json: VariantDetailPresenter.new(variant)
  end

  def destroy
    variant = Variant.view_scope.find_by!(id: params[:id])
    authorize variant
    soft_delete(variat, VariantDetailPresenter)
  end

  def datatable
    render json: VariantBrowseTable.new(view_context)
  end

  def typeahead_results
    render json: VariantTypeaheadResultsPresenter.new(view_context)
  end

  private
  def variant_params
    params.permit(:name, :description, :genome_build, :chromosome, :start, :stop, :reference_bases, :variant_bases, :representative_transcript, :chromosome2, :start2, :stop2, :reference_build, :representative_transcript2, :ensembl_version, variant_types: [])
  end

  def variant_gene_index(param_name, field_name)
    variants = Variant.index_scope
      .order('variants.id asc')
      .page(params[:page].to_i)
      .per(params[:count].to_i)
      .where(genes: { field_name => params[param_name] })

    render json: PaginatedCollectionPresenter.new(
      variants,
      request,
      VariantIndexPresenter,
      PaginationPresenter
    )
  end
end
