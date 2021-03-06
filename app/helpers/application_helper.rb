# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Re-create link_to with full functionality but providing button code wrapping
   def button_link_to(*args, &block)
         if block_given?
           options      = args.first || {}
           html_options = args.second
           concat(link_to(capture(&block), options, html_options))
         else
           name         = args.first
           options      = args.second || {}
           html_options = args.third

           url = url_for(options)

           # This is the only difference in this function from link_to.
           # Add the button class to any other sent along.
           html_options = {} unless html_options
           html_options.default = ""
           html_options[:class] = "btn " + html_options[:class]

           if html_options
             html_options = html_options.stringify_keys
             href = html_options['href']
             convert_options_to_javascript!(html_options, url)
             tag_options = tag_options(html_options)
           else
             tag_options = nil
           end

           href_attr = "href=\"#{url}\"" unless href
           "<a #{href_attr}#{tag_options}><span><span>#{name || url}</span></span></a>"
       end

   end

   def button_link_to_function(name, *args, &block)
       html_options = args.extract_options!.symbolize_keys

       html_options.default = ""
       html_options[:class] = "btn " + html_options[:class]

       function = block_given? ? update_page(&block) : args[0] || ''
       onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"

       content_tag(:button,"<span><span>" + name + "</span></span>", html_options.merge(:onclick => onclick))
   end

   def button_link_to_remote(name, options = {}, html_options = nil)
       button_link_to_function(name, remote_function(options), html_options || options.delete(:html))
   end
   
   def button_link_to_submit(name, *args, &block)
       html_options = args.extract_options!.symbolize_keys

       html_options.default = ""
       html_options[:class] = html_options[:class] + " btn"

       function = block_given? ? update_page(&block) : args[0] || ''
       
       content_tag(:button,"<span><span>" + name + "</span></span>", html_options.merge( :type => "submit"))
   end
   
   #Pagination page display helper
   def page_entries_info(collection, options = {})
     entry_name = options[:entry_name] ||
       (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))
     
     if collection.total_pages < 2
       case collection.size
       when 0; "No #{entry_name.pluralize} found"
       when 1; "Showing <b>1</b> #{entry_name}"
       else;   "Showing <b>all #{collection.size}</b> #{entry_name.pluralize}"
       end
     else
       %{Displaying <b>%d&nbsp;-&nbsp;%d</b> of <b>%d</b> #{entry_name.pluralize}} % [
         collection.offset + 1,
         collection.offset + collection.length,
         collection.total_entries
       ]
     end
   end

   #This method formats the flash content. The color gets intelligently selected based on the content of the message.   
   def render_flash( message )
     case message
     when /saved|updated/i
       color = "#8CC63F"
     when /new|attached/i
       color = "#8DB4D6"
     when /deleted|destroy|trash/i
       color = "red"
     when /NOT|error/
       color = "red"
     else
       color = "blue"
     end

     "<p style=\"color: #{color};\">" + message.to_s + "</p>"
   end
  
end
