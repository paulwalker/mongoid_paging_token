require 'mongoid'
require 'mongoid_paging_token/version'
require 'mongoid_paging_token/strategies/strategy'
require 'mongoid_paging_token/strategies/offset_strategy'
require 'mongoid_paging_token/strategies/one_field_boundary_strategy'
require 'mongoid_paging_token/strategies/two_field_boundary_strategy'
require 'mongoid_paging_token/paging_token'
require 'mongoid_paging_token/criteria'
require 'mongoid_paging_token/document'

::Mongoid::Criteria.send :include, MongoidPagingToken::Criteria
::Mongoid::Document.send :include, MongoidPagingToken::Document
