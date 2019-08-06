class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:edit, :update, :destroy]

  # GET /organizations
  # GET /organizations.json
  def index
    @organizations = RawOrganizations2.all
    @organizations.each do |organization|
      @funding_rounds=organization["data"]["relationships"]["funding_rounds"]
      categories=""
      @categories=organization["data"]["relationships"]["categories"]
      @categories["items"].each_with_index do |category,index|
        if index==0
          categories+="#{category["properties"]["name"]}"
          else
            categories+=",#{category["properties"]["name"]}"
          end
      end
      last_funding_date=Array.new
      @funding_rounds["items"].each_with_index do |category,index|
        last_funding_date<<Time.at(category["properties"]["updated_at"].to_i).to_s
      end
      last_funding_date.sort
      organization["data"]["properties"]["last_funding_date"]=last_funding_date.last
      organization["data"]["properties"]["categories"]=categories
      Organizations2.create(organization["data"]["properties"])
    end
  end
  def getTop100
    @orgs=RawOrganizations2.all
    @orgs.each do |org|
      if org.data["properties"]["number_of_investments"]>33
        CSV.open("#{org.data["properties"]["name"]}.csv","wb") do |csv|
        csv<<["Organization Name","Invested In","Rank"]
        url="https://api.crunchbase.com/v3.1/organizations/#{org["data"]["uuid"]}/investments?user_key=410bdb586887ca56ea64d429af28b17d"
        response = HTTParty.get(url)
        @investments = response.parsed_response
        @pages=@investments["data"]["paging"]["number_of_pages"]
        @nextpageurl=@investments["data"]["paging"]["next_page_url"]
        @count=Array.new
        @ranks=Array.new
        @investments["data"]["items"].each_with_index do |investment,index|
            unless @count.include?(investment["relationships"]["invested_in"]["properties"]["permalink"])
              @count<<investment["relationships"]["invested_in"]["properties"]["permalink"]
              @ranks<<investment["relationships"]["invested_in"]["properties"]["rank"]
              csv<<[org.data["properties"]["name"],investment["relationships"]["invested_in"]["properties"]["permalink"],investment["relationships"]["invested_in"]["properties"]["rank"]]
            end
        end
        while @pages>1
          url=@nextpageurl+"&user_key=410bdb586887ca56ea64d429af28b17d"
          response = HTTParty.get(url)
          @investmentsnext = response.parsed_response
          @nextpageurl=@investmentsnext["data"]["paging"]["next_page_url"]
          @investmentsnext["data"]["items"].each_with_index do |investment,index|
            unless @count.include?(investment["relationships"]["invested_in"]["properties"]["permalink"])
              @count<<investment["relationships"]["invested_in"]["properties"]["permalink"]
              @ranks<<investment["relationships"]["invested_in"]["properties"]["rank"]
              csv<<[org.data["properties"]["name"],investment["relationships"]["invested_in"]["properties"]["permalink"],investment["relationships"]["invested_in"]["properties"]["rank"]]
            end
          
          end
              @pages-=1
        end
      end
    end
  end
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def insertRawsecond
    url="https://api.crunchbase.com/v3.1/organizations?user_key=410bdb586887ca56ea64d429af28b17d&locations=Canada&organization_types=investor&page=3";
    response = HTTParty.get(url)
    result = response.parsed_response
    debugger
    @pages=result["data"]["paging"]["number_of_pages"]
    @nextpageurl=result["data"]["paging"]["next_page_url"]
    @current=result["data"]["paging"]["current_page"]
      result["data"]["items"].each_with_index do |organization,index|
        url="https://api.crunchbase.com/v3.1/organizations/#{organization["uuid"]}?user_key=410bdb586887ca56ea64d429af28b17d"
        response = HTTParty.get(url)
        result = response.parsed_response
        RawPeopleUsa.SaveRaw(result["data"]["properties"]["permalink"],result)
      end
      while @pages>=@current
        url=@nextpageurl+"&user_key=410bdb586887ca56ea64d429af28b17d"
        response = HTTParty.get(url)
        @orgnext = response.parsed_response
        @nextpageurl=@orgnext["data"]["paging"]["next_page_url"]
        @current=@orgnext["data"]["paging"]["current_page"]
        @orgnext["data"]["items"].each_with_index do |organization,index|
          url="https://api.crunchbase.com/v3.1/organizations/#{organization["uuid"]}?user_key=410bdb586887ca56ea64d429af28b17d"
          response = HTTParty.get(url)
          result = response.parsed_response
          debugger
          RawPeopleUsa.SaveRaw(result["data"]["properties"]["permalink"],result)
          end
      end
  end
  def insertRaw
    url="https://api.crunchbase.com/v3.1/organizations/56e40f5097c72a77255d1d97d5f30646?user_key=410bdb586887ca56ea64d429af28b17d";
    response = HTTParty.get(url)
    result = response.parsed_response
    RawOrganization.SaveRaw(result["data"]["properties"]["permalink"],result)
  end
  def show
    CSV.open("test1.csv","wb") do |csv|
      csv<<["Organization Name","Rank"]
    @org=RawOrganizations2.find_by(permalink:params[:id].to_s)
    url="https://api.crunchbase.com/v3.1/organizations/#{@org["data"]["uuid"]}/investments?user_key=410bdb586887ca56ea64d429af28b17d"
    response = HTTParty.get(url)
    @investments = response.parsed_response
    @pages=@investments["data"]["paging"]["number_of_pages"]
    @nextpageurl=@investments["data"]["paging"]["next_page_url"]
    @count=Array.new
    @ranks=Array.new
    @investments["data"]["items"].each_with_index do |investment,index|
        unless @count.include?(investment["relationships"]["invested_in"]["properties"]["permalink"])
          @count<<investment["relationships"]["invested_in"]["properties"]["permalink"]
          @ranks<<investment["relationships"]["invested_in"]["properties"]["rank"]
          csv<<[investment["relationships"]["invested_in"]["properties"]["permalink"],investment["relationships"]["invested_in"]["properties"]["rank"]]
        end
    end
    while @pages>1
     url=@nextpageurl+"&user_key=410bdb586887ca56ea64d429af28b17d"
     response = HTTParty.get(url)
     @investmentsnext = response.parsed_response
     @nextpageurl=@investmentsnext["data"]["paging"]["next_page_url"]
      @investmentsnext["data"]["items"].each_with_index do |investment,index|
        unless @count.include?(investment["relationships"]["invested_in"]["properties"]["permalink"])
          @count<<investment["relationships"]["invested_in"]["properties"]["permalink"]
          @ranks<<investment["relationships"]["invested_in"]["properties"]["rank"]
          csv<<[investment["relationships"]["invested_in"]["properties"]["permalink"],investment["relationships"]["invested_in"]["properties"]["rank"]]
        end
      
      end
          @pages-=1
    end
  end
end

  # GET /organizations/new
  def new
    debugger
    path=Rails.public_path
    file=path+"top.xlsx"
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    xlsx.default_sheet=xlsx.sheets[5]
    headers=Hash.new
    xlsx.row(1).each_with_index {|header,i|
    headers[header] = i
    }
    organizations=Array.new
    ((xlsx.first_row + 1)..xlsx.last_row).each do |myrow|
      organizations<<xlsx.row(myrow)[2]
    end
    organizations.each do |organization|
      unless organization.nil?
      url="https://api.crunchbase.com/v3.1/organizations/#{Organization.permalink(organization)}?user_key=410bdb586887ca56ea64d429af28b17d"
      response = HTTParty.get(url)
      result = response.parsed_response
      RawOrganization.SaveRaw(organization,result)
    end
    end
  end

  # GET /organizations/1/edit
  def edit
  end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
        format.html { redirect_to @organization, notice: 'Organization was successfully created.' }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end
  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: 'Organization was successfully updated.' }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render :edit }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_url, notice: 'Organization was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization
      @organization = Organization.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_params
      params.require(:organization).permit(:permalink)
    end
end
