script_directory = File.dirname(__FILE__)
load File.join(script_directory,"TextTokenizer.rb")
java_import java.util.regex.Pattern

class TextReplacer
	def initialize(needle)
		@newline_normalization = "\n"
		@needle = normalize_line_endings(needle)
		@pattern = Pattern.compile("\\Q#{@needle}\\E")

		@or_rgx = /\bor\b/i
		@and_rgx = /\band\b/i

		puts @pattern
	end

	def normalize_line_endings(input)
		return input.gsub(/\r?\n/,@newline_normalization)
	end

	def clean_string(input)
		
	end

	def get_query_criteria

		tokens = TextTokenizer.tokenize_text(@needle)
		tokens = tokens.uniq
		tokens = tokens.reject{|t|t =~ @or_rgx || t =~ @and_rgx}.map{|t| "\"#{t}\""}
		return tokens.join(" AND ")
	end

	def has_match(item)
		normalized_item_text = normalize_line_endings(item.getTextObject.toString)
		return @pattern.matcher(normalized_item_text).find
	end

	# Note this only works inside a Case.withWriteAccessBlock!
	def perform_replacement(item,replacement_text="")
		replacement_text ||= ""
		normalized_item_text = normalize_line_endings(item.getTextObject.toString)
		modified_text = @pattern.matcher(normalized_item_text).replaceAll(replacement_text)
		item.modify do |modifier|
			modifier.replaceText(modified_text)
		end
	end
end