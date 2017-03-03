#!/bin/bash
release_dir=./build/Release; release_name=AMM_$1
mkdir $release_dir/$release_name && mv $release_dir/AMM.app $_ && ln -s /Applications $_/
hdiutil create $release_dir/$release_name/$release_name.dmg -volname release_name -srcfolder $release_dir/$release_name
