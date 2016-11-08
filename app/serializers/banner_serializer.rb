class BannerSerializer < ActiveModel::Serializer
  attributes :id, :name, :landing_url, :file, :campaign_id

  def file
    {dataUrl: object.image.url}
  end
end
