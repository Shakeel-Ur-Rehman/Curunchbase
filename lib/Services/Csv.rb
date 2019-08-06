class Csv
    attr_accessor:@xlsx
    def initialize
        path=Rails.public_path
        file=path+"top.xlsx"
        xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
        xlsx.default_sheet=xlsx.sheets[9]
        headers=Hash.new
        xlsx.row(1).each_with_index {|header,i|
        headers[header] = i
        }
        organizations=Array.new
        ((xlsx.first_row + 1)..xlsx.last_row).each do |myrow|
        organizations<<xlsx.row(myrow)[2]
        end
    end
end