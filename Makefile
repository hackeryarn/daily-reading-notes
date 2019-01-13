deploy:
	# Build new files
	stack exec myblog clean
	stack exec myblog build
	# Get previous files
	git fetch --all
	git checkout -b master --track origin/master
	# Overwrite existing files with new files
	cp -a _site/. .
	# Commit
	git add -A
	git commit -m "Publish."
	# Push
	git push origin master:master
	# Restoration
	git checkout develop
	git branch -D master
