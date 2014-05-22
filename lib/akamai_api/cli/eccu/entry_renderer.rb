module AkamaiApi::Cli::Eccu
  class EntryRenderer
    def self.render entries
      output = ["----------"]
      entries.each do |e|
        output.concat new(e).render_entry
        output << "----------"
      end
      output.join "\n"
    end

    attr_reader :entry

    def initialize entry
      @entry = entry
    end

    def render
      [
        "----------",
        render_entry,
        "----------"
      ].join "\n"
    end

    def render_entry
      output = [
        "* Code    : #{entry.code}",
        entry_status,
        "            #{entry.status[:update_date]}",
        entry_property
      ]
      output << "* Notes   : #{entry.notes}" if entry.notes.present?
      output << "* Email   : #{entry.email}" if entry.email
      output << "* Uploaded by #{entry.uploaded_by} on #{entry.upload_date}"
      output << "* Content:\n#{entry.file[:content]}" if entry.file[:content].present?
      output
    end

    private

    def entry_property
      base = "* Property: #{entry.property[:name]} (#{entry.property[:type]})"
      if entry.property[:exact_match]
        [
          base,
          "            with exact match"
        ].join "\n"
      else
        base
      end
    end

    def entry_status
      if entry.status[:extended].present?
        "* Status  : #{entry.status[:code]} - #{entry.status[:extended]}"
      else
        "* Status  : #{entry.status[:code]}"
      end
    end
  end
end
