class BasicQueryValidator
	def self.check(query)
		begin
			# the query itself will not actually be performed, but will still be parsed to check for errors
			$current_case.search(query,{:limit => 0})
			return true
		rescue Exception => exc
			return exc.message
		end
	end
end