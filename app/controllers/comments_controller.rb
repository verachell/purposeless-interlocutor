class CommentsController < ApplicationController
	def index
		@comments = Comment.all.order("created_at DESC")
		@comment = Comment.new
	end
	
	def create
		@comment = Comment.new(comment_params)
		
		respond_to do |format|
			if @comment.save
				format.html { redirect_to comments_url, notice: "Your new status was successfully created" }
				compdesc = computer_comment(comment_params[:description])
				compcomment = Comment.new(description: compdesc, computer: true)
				compcomment.save!
			else
				format.html { render :new, status: :unprocessable_entity }
			end
		end
	end
	
	def destroy
		@comments = Comment.all
		@comments.destroy_all
		
		respond_to do |format|
			format.html { redirect_to comments_url, notice: "All statuses successfully deleted" }
		end
	end
	
	def about
	end
	
	private
	
	def comment_params
		params.require(:comment).permit(:description)
	end
	
	def computer_comment(humancomment)
		# given the string of a human comment, returns a string for the computer comment
		
		# set up variables
		more = ["how do you feel about the _?", "the _ could be significant", "tell me more about the _", "what do you think about the _?", "what was the _ like?", "the _ sounds interesting"]
		meaningless = ["very unusual","how interesting", "incredible!", "that's news to me", "what were you thinking?", "that's significant"]
		reply = ["I have no idea", "who knows?", "it's not clear to me", "I don't know", "that is up for debate", "only under certain conditions"]
		ireg = /\b[iI]\b|\b[Ww]e\b/
		myreg = /\b[Mm]y\b/	
		athereg = /\b([Tt]he|\b[aA]|\b[aA]n)\s(?<noun>\w{2,})\b/
		qreg = /\?$/
		imysub = false
		athe = false
		question = false
		noun = ""
		allowable_procs = Array.new
		
		# check properties of humancomment
		# test if we have a match for i/my - if so, change to you/your
		if ireg =~ humancomment
			humancomment.gsub!(ireg, "you")
			imysub = true
		end
		if myreg =~ humancomment
			humancomment.gsub!(myreg, "your")
			imysub = true
		end
		# check for the first noun - any word after a/an/the - might wind up with an adjective
		if athereg.match?(humancomment)
			mdata = athereg.match(humancomment)
			noun = mdata[:noun]
			# it is still theoretically possible for noun to be empty at this point
			# test for that here before pushing relevant proc to allowable procs
			if (noun) and (noun != "")
				athe = true
			end
		end
		# check for question
		if qreg =~ humancomment
			question = true
		end
		
		# define all procs, regardless of which ones are allowable for current value of humancomment
		# these procs define all the computer responses to human comments
		answer = Proc.new {reply.sample}
		fallback = Proc.new {meaningless.sample}
		youyour = Proc.new {humancomment + " - " + meaningless.sample}
		specnoun = Proc.new {more.sample.gsub("_", noun)}
		
		# now push names of allowable procs for current value of humancomment to array
		if question 
			allowable_procs.push(answer) 
		end
		if imysub
			allowable_procs.push(youyour) 
		end
		if athe 
			allowable_procs.push(specnoun)
		end
		# include fallback if allowable procs empty
		if allowable_procs.empty? 
			allowable_procs.push(fallback)
		end
		
		allowable_procs.sample.call
	end
	
end
