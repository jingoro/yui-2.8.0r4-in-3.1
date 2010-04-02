#! /usr/bin/env ruby

require 'open-uri'
require 'fileutils'

YUI_CDN_2IN3_BASE_URI = "http://yui.yahooapis.com/2in3.1/2.8.0/build"
YUI2_BUILD_DIR = "2.8.0r4/build"
YUI2_2IN3_OUTPUT_DIR = "2.8.0r4-in-3.1/build"

copies = []

Dir["#{YUI2_BUILD_DIR}/**/*.{js,css,swf,png,gif}"].sort.each do |path|
  rpath = path[(YUI2_BUILD_DIR.size + 1)..-1]
  case rpath
  when "swfstore/swf.js"
  when /-skin\.css$/
  when /yuitest\/yuitest_core/
    next
  when /\.js$/
    output_rpath = "yui2-" + rpath.sub("/", "/yui2-")
    if output_rpath =~ /^(yui2-connection\/yui2-connection_core)(.+)$/
      output_rpath = "yui2-connectioncore/yui2-connectioncore#{$2}"
    elsif output_rpath =~ /^(yui2-container\/yui2-container_core)(.+)$/
      output_rpath = "yui2-containercore/yui2-containercore#{$2}"
    elsif output_rpath =~ /^(yui2-editor\/yui2-simpleeditor)(.+)$/
      output_rpath = "yui2-simpleeditor/yui2-simpleeditor#{$2}"
    end
    copies << ["#{YUI_CDN_2IN3_BASE_URI}/#{output_rpath}", output_rpath]
  when /^assets\//
    copies << [path, rpath]
  when /\.css$/
    if rpath =~ /^((base|fonts|grids|reset).*)\/(.+\.css)/
      output_rpath = "yui2-#{$1}/yui2-#{$3}"
    elsif rpath =~ /^(.+)\/assets\/skins\/sam\/(.+)$/
      output_rpath = "yui2-skin-sam-#{$1}/assets/skins/sam/yui2-skin-sam-#{$2}"
    else
      output_rpath = "yui2-skin-sam-" + rpath
    end
    if output_rpath == "yui2-skin-sam-editor/assets/skins/sam/yui2-skin-sam-simpleeditor.css"
      output_rpath = "yui2-skin-sam-simpleeditor/assets/skins/sam/yui2-skin-sam-simpleeditor.css"
    end
    copies << [path, output_rpath]
    if output_rpath !~ /\-min\.css$/ && output_rpath =~ /^(.+)\/assets\/skins\/sam\/(.+)$/
      copies << [path, output_rpath.sub(/\.css/, "-min.css")]
    end
  else
    copies << [path, "yui2-skin-sam-" + rpath]
  end
end

copies.each do |source, dest|
  output_path = "#{YUI2_2IN3_OUTPUT_DIR}/#{dest}"
  output_dir = File.dirname(output_path)
  puts "Creating #{output_path}..."
  FileUtils.mkdir_p output_dir
  File.open(output_path, "w").write(open(source).read)
end
