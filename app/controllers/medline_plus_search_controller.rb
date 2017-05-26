class MedlinePlusSearchController < ApplicationController
  before_action :check_role

  def search
    uri = URI.parse('https://wsearch.nlm.nih.gov/ws/query?db=healthTopics&term=asthma')
    doc = Nokogiri::XML(Net::HTTP.get_response(uri).body)
    log 1, 3
    render json: Hash.from_xml(doc.to_s)['nlmSearchResult']['list']['document'].map{ |document| { title: document['content'][0], description: document['content'][3] } }
  end

  protected

  def check_role
    authorize EducationMaterial, :display?
  end
end