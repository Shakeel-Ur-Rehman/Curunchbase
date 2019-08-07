namespace :curunchbase do
  desc "Generate CSV"
  task generatecsv: :environment do
    countries=["united states","canada"]
    api_key = "410bdb586887ca56ea64d429af28b17d"
    api_base_url = "https://api.crunchbase.com/v3.1"

    path=Rails.public_path  
    @investors=Investor.limit(100)
    @investors.each do |investor|
    CSV.open("#{path}/investorslist/Batch/#{Organization.permalink(investor.organization_url)}.csv","wb") do |csv|
          csv<<["Investor","Organization Name","Permalink","Headequarters Location","Description","CB Rank","Website"]
            if investor.organization_url.include?("/person")
            url=Organization.EscapeURL("#{api_base_url}/people/#{Organization.permalink(investor.organization_url)}/investments?user_key=#{api_key}")
            else
              url=Organization.EscapeURL("#{api_base_url}/organizations/#{Organization.permalink(investor.organization_url)}/investments?user_key=#{api_key}")
            end
            response = HTTParty.get(url)
          @unique_organizations = Array.new
          @investments = response.parsed_response
          @pages=@investments["data"]["paging"]["number_of_pages"]
          @nextpageurl=@investments["data"]["paging"]["next_page_url"]          
          @investments["data"]["items"].each_with_index do |investment,index|
            @investment_details = investment["relationships"]["invested_in"]["properties"]

            @unique_organizations.include?(@investment_details["permalink"])? next :        
            @unique_organizations<<@investment_details["permalink"]
            if @investment_details["total_funding_usd"]>=1000000 && !@investment_details["is_closed"]
                url=Organization.EscapeURL("#{api_base_url}/organizations/#{@investment_details["permalink"]}/headquarters?user_key=#{api_key}")
                response = HTTParty.get(url)
                @organization = response.parsed_response
                if @organization.class==Hash && @organization["data"]["paging"]["total_items"].to_i>0
                  if countries.include?(@organization["data"]["items"][0]["properties"]["country"].downcase)
                  csv<<[investor.name,@investment_details["name"],@investment_details["permalink"],@organization["data"]["items"][0]["properties"]["country"],@investment_details["description"],@investment_details["rank"],@investment_details["api_url"]]
                  end  
                end                   
            end            
          end  # End of loop.
        #while here
        while @pages>1
          url=@nextpageurl+"&user_key=#{api_key}"
          response = HTTParty.get(url)
          @investmentsnext = response.parsed_response
          @nextpageurl=@investmentsnext["data"]["paging"]["next_page_url"]
          @investmentsnext["data"]["items"].each_with_index do |investment,index|
            @investment_details = investment["relationships"]["invested_in"]["properties"]
            @unique_organizations.include?(@investment_details["permalink"])? next :        
            @unique_organizations<<@investment_details["permalink"]
            if @investment_details["total_funding_usd"]>=1000000 && !@investment_details["is_closed"]
                url=Organization.EscapeURL("#{api_base_url}/organizations/#{@investment_details["permalink"]}/headquarters?user_key=#{api_key}")
                response = HTTParty.get(url)
                @organization = response.parsed_response
                if @organization.class==Hash && @organization["data"]["paging"]["total_items"].to_i>0
                    if countries.include?(@organization["data"]["items"][0]["properties"]["country"].downcase)
                    csv<<[investor.name,@investment_details["name"],@investment_details["permalink"],@organization["data"]["items"][0]["properties"]["country"],@investment_details["description"],@investment_details["rank"],@investment_details["api_url"]]
                    end  
                  end           
            end            
          end
              @pages-=1
        end   
      end  #end while
    end  # end for main investors loop.

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
