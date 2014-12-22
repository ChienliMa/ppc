# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# require ppc for version
require 'ppc'

Gem::Specification.new do |spec|
  spec.name          = "ppc"
  spec.version       = PPC::VERSION
  spec.authors       = ["Chienli Ma, 刘梦晨， 刘明"]
  spec.email         = ["maqianlie@gmail.com, liuyu_tc@163.com, seoaqua@qq.com"]
  spec.summary       = %q{ppc api for  baidu qihu sogou}
  spec.description   = %q{ppc api for  baidu qihu sogou}
  spec.homepage      = "http://github.com/elong/ppc"
  spec.license       = "GNU"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'httparty', '~> 0.13', '>= 0.13.0'
  spec.add_dependency 'savon',  '~> 3.0', '>= 3.0.0'

end
