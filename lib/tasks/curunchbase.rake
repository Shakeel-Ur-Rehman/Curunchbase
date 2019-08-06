namespace :curunchbase do
  desc "Generate CSV"
  task generatecsv: :environment do
    countries=["United Stats","Canada"]
    path=Rails.public_path  
    @org=Investor.find_by(organization_url:"https://www.crunchbase.com/organization/vivo-capital") 
    CSV.open("#{path}/investorslist/investorslist2.csv","wb") do |csv|
          csv<<["Investor","Organization Name","Permalink","Headequarters Location","Description","CB Rank","Website"]
          url="https://api.crunchbase.com/v3.1/organizations/#{Organization.permalink(@org.organization_url)}/investments?user_key=410bdb586887ca56ea64d429af28b17d"
          response = HTTParty.get(url)
          @count=Array.new
          @investments = response.parsed_response
          @pages=@investments["data"]["paging"]["number_of_pages"]
          @nextpageurl=@investments["data"]["paging"]["next_page_url"]
          @investments["data"]["items"].each_with_index do |investment,index|
            @counter=0;
            if investment["relationships"]["invested_in"]["properties"]["total_funding_usd"]>1000000&&investment["relationships"]["invested_in"]["properties"]["is_closed"]=false
              @counter+=1
              unless @count.include?(investment["relationships"]["invested_in"]["properties"]["permalink"])
                url="https://api.crunchbase.com/v3.1/organizations/#{investment["relationships"]["invested_in"]["properties"]["permalink"]}/headquarters?user_key=410bdb586887ca56ea64d429af28b17d"
                response = HTTParty.get(url)
                @organization = response.parsed_response
                if countries.include?(@organization["data"]["items"][0]["properties"]["country"])
                  csv<<[@org.name,investment["relationships"]["invested_in"]["properties"]["name"],investment["relationships"]["invested_in"]["properties"]["permalink"],@organization["data"]["items"][0]["properties"]["country"],investment["relationships"]["invested_in"]["properties"]["description"],investment["relationships"]["invested_in"]["properties"]["rank"],investment["relationships"]["invested_in"]["properties"]["api_url"]]
                end
            end
          end
        end
        #while here
        while @pages>1
          url=@nextpageurl+"&user_key=410bdb586887ca56ea64d429af28b17d"
          response = HTTParty.get(url)
          @investmentsnext = response.parsed_response
          @nextpageurl=@investmentsnext["data"]["paging"]["next_page_url"]
          @investmentsnext["data"]["items"].each_with_index do |investment,index|
            if investment["relationships"]["invested_in"]["properties"]["total_funding_usd"]>1000000 &&investment["relationships"]["invested_in"]["properties"]["is_closed"]=false
              unless @count.include?(investment["relationships"]["invested_in"]["properties"]["permalink"])
                url="https://api.crunchbase.com/v3.1/organizations/#{investment["relationships"]["invested_in"]["properties"]["permalink"]}/headquarters?user_key=410bdb586887ca56ea64d429af28b17d"
                response = HTTParty.get(url)
                @organization = response.parsed_response
                if countries.include?(@organization["data"]["items"][0]["properties"]["country"])
                  csv<<[@org.name,investment["relationships"]["invested_in"]["properties"]["name"],investment["relationships"]["invested_in"]["properties"]["permalink"],@organization["data"]["items"][0]["properties"]["country"],investment["relationships"]["invested_in"]["properties"]["description"],investment["relationships"]["invested_in"]["properties"]["rank"],investment["relationships"]["invested_in"]["properties"]["api_url"]]
                end
            end
          end
          end
              @pages-=1
        end
        #end while
      end  
    end
  desc "Get Investors List"
  task getinvestorslist: :environment do
    path=Rails.public_path
    @orgs=Organizations2.where(is_closed:false,number_of_investments:{'$gt'=>25}).no_timeout
    @counts=0
    CSV.open("#{path}/investorslist/investors.csv","wb") do |csv|
        csv<<["Organization Name","number of unique orgs","number of investments"]
      @orgs.each do |org|
        puts @counts+=1  
        url="https://api.crunchbase.com/v3.1/organizations/#{org.permalink}/investments?user_key=410bdb586887ca56ea64d429af28b17d"
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
              end
          end
              @pages-=1
        end
        if @count.count>=25
          csv<<[org.permalink,@count.count,org.number_of_investments]
        end
    end
  end
  end

end
