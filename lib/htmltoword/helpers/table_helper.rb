module Htmltoword
  module TableHelper
    #calculate column number of this table by calc first line
    def calc_table_cols(table)
      col_num = 0
      table.css('tr').first.children().each do |td|
        if td['colspan'] == nil
          col_num += td['colspan'].to_i
        else
          col_num += 1
        end
      end
      return col_num
    end

    def fix_line(table, trs, row_num)
      # puts 'row_num=>'+row_num.to_s
      trs[row_num].children().each do |td|
        colspan_num = 1
        rowspan_num = 1
        colspan_num = td['colspan'].to_i unless td['colspan'] == nil
        rowspan_num = td['rowspan'].to_i unless td['rowspan'] == nil
        if colspan_num>1
          index = 1
          name = td.to_s.match(/^\s*<th/) ? 'th' : 'td';
          while index<colspan_num
            node = Nokogiri::XML::Node.new name, table
            node['rowspans'] = rowspan_num unless rowspan_num == 1
            node['vmerge'] = 1 unless rowspan_num == 1
            node['hmerge'] = 1
            td.add_next_sibling node
            index+=1
          end
        end
      end
    end

    def fix_vertical(table, trs, row_num)
      col_index =0
      trs[row_num].children().each do |td|
        rowspan_num = 1
        rowspan_num = td['rowspan'].to_i unless td['rowspan'] == nil
        rowspan_num = td['rowspans'].to_i unless td['rowspans'] == nil
        if rowspan_num > 1
          index = 1
          name = td.to_s.match(/^\s*<th/) ? 'th' : 'td';
          while index<rowspan_num
            node = Nokogiri::XML::Node.new name, table
            # if `td` is the true dom then the w:vmerge attr should be 'continue'
            node['vmerge'] = 2
            # if `td` is the vdom then the w:vmerge attr should be ''
            node['vmerge'] = 1 unless td['rowspans'] == nil
            if (td['colspan'] != nil && td['colspan'].to_i > 1)||td['hmerge']!=nil
              node['hmerge'] = 1
            end
            if trs[row_num+index].children()[col_index] != nil
              trs[row_num+index].children()[col_index].add_previous_sibling node
            else trs[row_num+index].children()[col_index-1] != nil
            trs[row_num+index].children()[col_index-1].add_next_sibling node
            end
            index+=1
          end
        end
        if td['rowspans'] != nil
          td['rowspans'] = ''
        end
        col_index+=1
      end
    end

    def fix_table(table,part)
      head_trs = part.css('tr')
      length = head_trs.length
      # puts 'length=>'+length.to_s
      index = 0
      while index<length
        # puts 'index=>'+index.to_s
        fix_line(table, head_trs, index)
        index+=1
      end
      index = 0
      while index<length
        # puts 'index1=>'+index.to_s
        fix_vertical(table, head_trs, index)
        index+=1
      end
    end

    def fix_tables(sources)
      sources.css('table').each do |table|
        fix_table table,table.css('thead')
        fix_table table,table.css('tbody')
      end
    end
  end
end