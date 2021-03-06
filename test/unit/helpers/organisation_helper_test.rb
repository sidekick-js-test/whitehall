require "test_helper"

class OrganisationHelperTest < ActionView::TestCase
  include ApplicationHelper
  test "returns acroynm in abbr tag if present" do
    organisation = build(:organisation, acronym: "BLAH", name: "Building Law and Hygiene")
    assert_equal %{<abbr title="Building Law and Hygiene">BLAH</abbr>}, organisation_display_name(organisation)
  end

  test "returns name when acroynm is nil" do
    organisation = build(:organisation, acronym: nil, name: "Building Law and Hygiene")
    assert_equal "Building Law and Hygiene", organisation_display_name(organisation)
  end

  test "returns name when acroynm is empty" do
    organisation = build(:organisation, acronym: "", name: "Building Law and Hygiene")
    assert_equal "Building Law and Hygiene", organisation_display_name(organisation)
  end

  test "returns name formatted for logos" do
    organisation = build(:organisation, name: "Building Law and Hygiene", logo_formatted_name: "Building Law\nand Hygiene")
    assert_equal "Building Law<br/>and Hygiene", organisation_logo_name(organisation)
    assert_equal "Building Law and Hygiene", organisation_logo_name(organisation, false)
  end

  test 'organisation_wrapper should place org specific class onto the div' do
    organisation = build(:organisation, slug: "organisation-slug-yeah", name: "Building Law and Hygiene")
    html = organisation_wrapper(organisation) {  }
    div = Nokogiri::HTML.fragment(html)/'div'
    assert_match /organisation-slug-yeah/, div.attr('class').value
  end

  test 'organisation_wrapper should place brand colour class onto the div' do
    organisation = build(:organisation, organisation_brand_colour_id: OrganisationBrandColour::HMGovernment.id)
    html = organisation_wrapper(organisation) {  }
    div = Nokogiri::HTML.fragment(html)/'div'
    assert_match /hm-government-brand-colour/, div.attr('class').value
  end

  test 'organisation_brand_colour_class generates blank class when org has no brand colour' do
    org = build(:organisation)
    assert_equal organisation_brand_colour_class(org), ""
  end

  test 'organisation_brand_colour_class generates correct class for brand colour' do
    org = build(:organisation, organisation_brand_colour_id: 2)
    assert_equal organisation_brand_colour_class(org), "cabinet-office-brand-colour"
  end

  test 'extra_board_member_class returns clear_person at correct interval when many important board members' do
    organisation = stub('organistion', important_board_members: 2)
    assert_equal 'clear-person', extra_board_member_class(organisation, 0)
    assert_equal '', extra_board_member_class(organisation, 1)
    assert_equal '', extra_board_member_class(organisation, 2)
    assert_equal '', extra_board_member_class(organisation, 3)
    assert_equal 'clear-person', extra_board_member_class(organisation, 4)
  end

  test 'extra_board_member_class returns clear_person at correct interval when one important board member' do
    organisation = stub('organistion', important_board_members: 1)
    assert_equal 'clear-person', extra_board_member_class(organisation, 0)
    assert_equal '', extra_board_member_class(organisation, 1)
    assert_equal '', extra_board_member_class(organisation, 2)
    assert_equal 'clear-person', extra_board_member_class(organisation, 3)
  end

  test 'link_to_all_featured_policies returns policies_path filtered by the supplied organisation if it has no featured_topics_and_policies_list' do
    o = build(:organisation); o.stubs(:to_param).returns('woo')
    assert_equal link_to('See all our policies', policies_path(departments: [o])), link_to_all_featured_policies(o)
  end

  test 'link_to_all_featured_policies returns policies_path if the supplied organisation has a featured_topics_and_features_list but it does not link_to_filtered_policies' do
    o = build(:organisation); o.stubs(:to_param).returns('woo')
    list = build(:featured_topics_and_policies_list, link_to_filtered_policies: false)
    o.featured_topics_and_policies_list = list
    assert_equal link_to('See all our policies', policies_path), link_to_all_featured_policies(o)
  end

  test 'link_to_all_featured_policies returns policies_path filtered by the supplied organisation if it has featured_topics_and_features_list\'s org that does link_to_filtered_policies' do
    o = build(:organisation); o.stubs(:to_param).returns('woo')
    list = build(:featured_topics_and_policies_list, link_to_filtered_policies: true)
    assert_equal link_to('See all our policies', policies_path(departments: [o])), link_to_all_featured_policies(o)
  end
  
  test 'organisation_count_paragraph includes the number of orgs in a filterable container' do
    orgs = [build(:organisation), build(:organisation)]
    render text: organisation_count_paragraph(orgs)
    assert_select '.js-filter-count', text: '2'
  end

  test 'organisation_count_paragraph includes the number of orgs live on govuk in a container' do
    orgs = [build(:organisation, govuk_status: 'live'), build(:organisation, govuk_status: 'joining')]
    render text: organisation_count_paragraph(orgs)
    assert_select '.on-govuk'
    assert_select '.on-govuk', text: '1 live on GOV.UK'
  end

  test 'organisation_count_paragraph includes "all" instead of a number, if all supplied orgs are live on govuk in a container' do
    orgs = [build(:organisation, govuk_status: 'live'), build(:organisation, govuk_status: 'live')]
    render text: organisation_count_paragraph(orgs)
    assert_select '.on-govuk', text: 'All live on GOV.UK'
  end

  test 'organisation_count_paragraph won\'t include the live on govuk container if you ask it not to' do
    orgs = [build(:organisation, govuk_status: 'live'), build(:organisation, govuk_status: 'live')]
    render text: organisation_count_paragraph(orgs, with_live_on_govuk: false)
    assert_select '.on-govuk', count: 0
  end
end

class OrganisationHelperDisplayNameWithParentalRelationshipTest < ActionView::TestCase
  include OrganisationHelper

  def strip_html_tags(html)
    html.gsub(/<[^>]*?>/, '')
  end

  def assert_relationship_type_is_described_as(type_name, expected_description)
    parent = create(:organisation)
    child = create(:organisation, parent_organisations: [parent],
      organisation_type: create(:organisation_type, name: type_name))
    expected_text = %Q{#{child.name} #{expected_description} the #{parent.name}}
    actual_html = organisation_display_name_and_parental_relationship(child)
    assert_equal expected_text, strip_html_tags(actual_html)
  end

  def assert_definite_article_skipped(parent_organisation_name)
    parent = create(:organisation, name: parent_organisation_name)
    child = create(:organisation, parent_organisations: [parent])
    actual_html = organisation_display_name_and_parental_relationship(child)
    assert_match /of #{parent.name}/, strip_html_tags(actual_html)
  end

  def assert_display_name_text(organisation, expected_text)
    actual_html = organisation_display_name_and_parental_relationship(organisation)
    assert_equal expected_text, strip_html_tags(actual_html)
  end

  test 'basic sentence construction' do
    parent = create(:ministerial_department, acronym: "DBR", name: "Department of Building Regulation")
    child = create(:organisation, acronym: "BLAH",
      name: "Building Law and Hygiene", parent_organisations: [parent],
      organisation_type: create(:organisation_type, name: "Executive agencies"))
    expected = %{BLAH is an executive agency of the Department of Building Regulation}
    assert_display_name_text child, expected
  end

  test 'string returned is html safe' do
    parent = create(:ministerial_department, name: "Department of Economy & Trade")
    child = create(:organisation, acronym: "B&B",
      name: "Banking & Business", parent_organisations: [parent],
      organisation_type: create(:organisation_type, name: "Executive & important agencies"))
    expected = %{B&amp;B is an executive &amp; important agency of the Department of Economy &amp; Trade}
    assert_display_name_text child, expected
    assert organisation_display_name_and_parental_relationship(child).html_safe?
  end

  test 'description of parent organisations' do
    parent = create(:ministerial_department, acronym: "DBR", name: "Department of Building Regulation")
    expected = %{DBR is a ministerial department}
    assert_display_name_text parent, expected
  end

  test 'links to parent organisation' do
    parent = create(:organisation)
    child = create(:organisation, parent_organisations: [parent])
    assert_match %r{the <a href="/government/organisations/#{parent.to_param}">#{parent.name}</a>}, organisation_display_name_and_parental_relationship(child)
  end

  test 'relationship types are described correctly' do
    assert_relationship_type_is_described_as('Ministerial departments', 'is a ministerial department of')
    assert_relationship_type_is_described_as('Non-ministerial departments', 'is a non-ministerial department of')
    assert_relationship_type_is_described_as('Executive agencies', 'is an executive agency of')
    assert_relationship_type_is_described_as('Executive non-departmental public bodies', 'is an executive non-departmental public body of')
    assert_relationship_type_is_described_as('Advisory non-departmental public bodies', 'is an advisory non-departmental public body of')
    assert_relationship_type_is_described_as('Tribunal non-departmental public bodies', 'is a tribunal non-departmental public body of')
    assert_relationship_type_is_described_as('Public corporations', 'is a public corporation of')
    assert_relationship_type_is_described_as('Independent monitoring bodies', 'is an independent monitoring body of')
    assert_relationship_type_is_described_as('Others', 'works with')
  end

  test 'definite article skipped for certain parent organisations' do
    assert_definite_article_skipped 'HM Treasury'
    assert_definite_article_skipped 'Ordnance Survey'
  end

  test 'definite article skipped if name starts with "The"' do
    assert_definite_article_skipped 'The National Archives'
  end

  test 'multiple parent organisations reflected as in copy' do
    parent = create(:organisation)
    parent2 = create(:organisation)
    child = create(:organisation, parent_organisations: [parent, parent2])
    result = organisation_display_name_and_parental_relationship(child)
    assert_match parent.name, result
    assert_match parent2.name, result
  end
  
  
end

class OrganisationSiteThumbnailPathTest < ActionView::TestCase
  include OrganisationHelper

  test 'organisation_site_thumbnail_path contains the organisation slug' do
    organisation = stub('organisation', slug: 'slug')
    assert_match %r{organisation_screenshots/slug.png}, organisation_site_thumbnail_path(organisation)
  end

  test 'organisation_site_thumbnail_path uses the placeholder image if the file does not exist' do
    organisation = stub('organisation', slug: 'slug')
    stubs(:image_path).raises(Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError).then.returns("return_path")
    assert_equal "return_path", organisation_site_thumbnail_path(organisation)
  end
end
