#!/bin/bash

echo "Enter the page name:"
read -r page_name

echo "Choose the template for the page:"
templates=(templates/*)
select template in "${templates[@]}"; do
    if [ -n "$template" ]; then
        break
    else
        echo "Invalid selection. Please choose a valid template."
    fi
done

echo "Enter the title of the page:"
read -r title

echo "Enter the content of the page:"
read -r content

# Create the static page
mkdir -p pages
sed -e "s/\$title/$title/g" -e "s/\$content/$content/g" "$template" > "pages/$page_name.html"

echo "Page created successfully: pages/$page_name.html"
