# frozen_string_literal: true

module DataMigrations
  class Base
    attr_accessor :errors, :total, :title, :progress

    def initialize(total, title)
      self.total  = total
      self.title  = title_format(title)
      self.errors = []
    end

    def run!
      header(title)
      total_formatted

      run_migration
      output
      if errors.empty?
        output
        output ' ✔  Great! There were no errors encountered.'
      else
        output " 💩  #{errors.size.to_s.red} errors recorded, out of  #{total.to_s.blue} total objects."
      end
    end

    def increment
      output_inline '.'
    end

    protected

    def title_format(text)
      format('%25s', text)
    end

    def output(*args)
      $stdout.puts(*args)
    end

    def output_inline(*args)
      print(*args) # rubocop:todo Rails/Output
    end

    def total_formatted
      output "Total: #{total}"
      output
    end

    private

    # rubocop:disable Style/StringConcatenation
    def header(msg)
      output '\n'\
      '——————————————————————————————————' + ' ' +
             msg + ' ' \
      '——————————————————————————————————' + '\n\n'
    end
    # rubocop:enable Style/StringConcatenation
  end
end
