require "java"
java_import java.io.StringReader
java_import org.apache.lucene.analysis.standard.StandardTokenizer
java_import org.apache.lucene.analysis.tokenattributes.CharTermAttribute

class TextTokenizer
	def self.tokenize_text(text)
		reader = StringReader.new(text)
		tokenizer = nil
		if NuixConnection.getCurrentNuixVersion.isLessThan("7.0")
			java_import org.apache.lucene.util.Version
			tokenizer = StandardTokenizer.new(Version::LUCENE_30,reader)
		else
			tokenizer = StandardTokenizer.new
			tokenizer.setReader(reader)
		end
		att = tokenizer.getAttribute(CharTermAttribute.java_class)
		tokenizer.reset
		tokens = []
		while tokenizer.incrementToken
			tokens << att.toString
		end
		tokenizer.end
		tokenizer.close
		return tokens
	end
end