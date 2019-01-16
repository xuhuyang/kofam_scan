module KOHMM
  class OutputFormatter
    class HitDetailFormatter < OutputFormatter
      def initialize
        @report_unannotated = false
      end

      def format(result, output)
        output << header
        result.query_list.each do |query|
          hits = result.for_gene(query)
          if hits.empty?
            output << format_empty_hit(query) << "\n" if @report_unannotated
            next
          end

          hits.sort_by(&:score).reverse_each do |hit|
            output << format_hit(hit) << "\n"
          end
        end
      end

      private

      def template
        "%1s %-19.19s %-6s %7.2f %6.1f %9.2g %s"
      end

      def template_for_string
        template.gsub(/\.\d+[fg]/, "s")
      end

      def header
        "#{header_first_line}\n#{header_delimiter_line}\n"
      end

      def header_first_line
        template_for_string % %w[# gene\ name KO thrshld score E-value KO\ definition]
      end

      def header_delimiter_line
        lengths = template.scan(/%-?(\d+)(?:\.\d+)?[sfg]/).map { |(len)| len.to_i }
        lengths.shift
        lengths << 21

        "#-" + lengths.map { |i| '-' * i }.join(' ')
      end

      def format_hit(hit)
        mark = hit.above_threshold? ? '*' : nil
        template % [mark, hit.gene_name, hit.ko.name, hit.ko.threshold,
                    hit.score, hit.e_value, hit.ko.definition]
      end

      def format_empty_hit(query)
        template_for_string % ([nil, query] + ['-'] * 5)
      end
    end
  end
end
