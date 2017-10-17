module BrInvoicesPdf
  module Nfce
    module Renderer
      module PaymentForms
        extend BaseRenderer

        module_function

        def execute(pdf, data)
          pdf.font_size(6) do
            width = page_content_width(pdf)
            table_data = has_cashback(data) ? payments_table_data_with_cashback(data) : payments_table_data(data)
            render_table(pdf, table_data, width)
          end

          pdf.move_down(5)
        end

        def has_cashback(data)
          !data[:payments].map { |payment| payment[:cashback] }.compact.empty?
        end

        def render_table(pdf, table_data, width)
          pdf.table(table_data, width: width) do |table|
            format_table(table, table_data)
          end
        end
        private_class_method :render_table

        # :reek:FeatureEnvy
        def format_table(table, table_data)
          table.columns([0, 1, 2]).valign = :center
          table.columns(1).align = :right
          table_size = table_data.size
          table.row([0, table_size - 1]).font_style = :bold
        end
        private_class_method :format_table

        PAYMENTS_TABLE_BASE_DATA = [['FORMA DE PAGAMENTO', 'VALOR']].freeze
        def payments_table_data(data)
          payments_data = data[:payments].reduce(PAYMENTS_TABLE_BASE_DATA) do |result, cur|
            result + [[cur[:type], format_currency(cur[:amount])]]
          end

          add_default_values(payments_data, data)
        end
        private_class_method :payments_table_data

        PAYMENTS_TABLE_BASE_DATA_WITH_CASHBACK = [['FORMA DE PAGAMENTO', 'VALOR', 'TROCO']].freeze
        def payments_table_data_with_cashback(data)
          payments_data = data[:payments].reduce(PAYMENTS_TABLE_BASE_DATA_WITH_CASHBACK) do |result, cur|
            result + [[cur[:type], format_currency(cur[:amount]), cur[:cashback]]]
          end

          add_default_values(payments_data, data)
        end
        private_class_method :payments_table_data

        def add_default_values(payments_data, data)
          totals = data[:totals]
          if has_cashback(data)
            payments_data.push(['TOTAL', format_currency(totals[:total]), nil])
          else
            payments_data.push(['TOTAL', format_currency(totals[:total])])
          end
        end
        private_class_method :add_default_values
      end
    end
  end
end
