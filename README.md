
mongoid_paging_token extends Mongoid::Criteria so that it can generate a paging token appropriate to the criteria.  The "paging token" value is actually a Mongoid::Criteria serialized to a web safe string that will provide the results for the next page specific to the limit and sorting options in the Mongoid::Criteria instance.

Paging with this gem potentially provides a more accurate methodology of paging through a volatile list of items as the condtion generating by the paging token is a boundary condition on the sorted field(s) rather than the use of an offset.  The next page will always start with the correct next item that follows the last item from the current page.


### Installation

`gem 'mongoid_paging_token'`

### Usage

```
class Foo
  include ::Mongoid::Document

  field :title, type: String
end

1.upto(5).each do |i|
  Foo.create! title: "title_#{i}"
end

page_one = Foo.asc(:title).limit(2)
token = page_one.paging_token

page_one.map(&:title)
=> ['title_1', 'title_2']

page_two = Foo.by_paging_token(token)
token = page_two.paging_token

page_two.map(&:title)
=> ['title_3', 'title_4']

page_three = Foo.by_paging_token(token)
page_three.map(&:title)
=> ['title_5']

page_three.token
=> nil 
```

Note that it is perfectly fine to use any additional criteria outside of sorting and limiting and this will be included in the serialized criteria.
```
page_one = Foo.asc(:title).limit(2).nin('title_1', 'title_99')
token = page_one.paging_token

page_one.map(&:title)
=> ['title_2', 'title_3']

Foo.by_paging_token(token).map(&:title)
=> ['title_4', 'title_5']
```

#### Mongoid::Criteria cache option

Generation of the paging token requires access to the entries in the criteria.  Mongoid does not normally set a reference to the results returned from the criteria, so each iteration or access of the entries results in an additional query to Mongo.  Because of this it is important that the cache option be set to true which tells Mongoid to set an instance variable reference to the results the first time so that additional references to entries do not result in additional queries to Mongo.  This is normally done with a simple call to #cache when generating the criteria `Foo.asc(:title).limit(10).cache`.  When the paging_token is used, the cache option will be set to true if it is not already true.  This is only provided as a convenience for the case in which you know you will access the paging_token before iterating through the entries (as in the code example above).  If your code iterates through the entries on the criteria before you refence the paging_token, be sure to set the cache option so as to not generate an additional request to Mongo.

It is not necessary to set the cache option when using the #by_paging_token method on the Document as the token already has the option serialized.

#### Multiple Field sorting

If the field by which you are sorting is not unique, you will want to sort by more than one field for paging to return the proper results.  mongoid_paging_token handles this as long as you have specified a second field `Foo.asc(:title, :id).limit(10).cache`.  This gem does not support sorting on more than two fields at this time and will raise a `NotImplementedError` if attempted.  This does not mean that you cannot sort on more than two fields, it just means you can't access the #paging_token while doing so.


