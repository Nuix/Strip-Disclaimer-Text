script_directory = File.dirname(__FILE__)
load File.join(script_directory,"TextTokenizer.rb")
java_import java.util.regex.Pattern

class TextReplacer
	attr_accessor :regular_expression

	def initialize(needle)
		@needle = needle
		@regular_expression = build_regular_expression(needle)
		@pattern = Pattern.compile(@regular_expression,Pattern::CASE_INSENSITIVE)

		@or_rgx = /\bor\b/i
		@and_rgx = /\band\b/i

		puts @pattern
	end

	def build_regular_expression(input)
		return input
			.gsub(/\r?\n/,"\\r?\\n")
			.split(/\s+/)
			.map{|c|"\\Q#{c}\\E"}
			.join("\\s+")
	end

	def get_query_criteria
		tokens = TextTokenizer.tokenize_text(@needle)
		tokens = tokens.uniq
		tokens = tokens.reject{|t|t =~ @or_rgx || t =~ @and_rgx}.map{|t| "\"#{t}\""}
		return tokens.join(" AND ")
	end

	def has_match(item)
		return @pattern.matcher(item.getTextObject.toString).find
	end

	# Note this only works inside a Case.withWriteAccessBlock!
	def perform_replacement(item,replacement_text="")
		replacement_text ||= ""
		modified_text = @pattern.matcher(item.getTextObject.toString).replaceAll(replacement_text)
		item.modify do |modifier|
			modifier.replaceText(modified_text)
		end
	end
end