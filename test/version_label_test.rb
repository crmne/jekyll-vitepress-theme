require_relative 'test_helper'

class VersionLabelTest < Minitest::Test
  VersionLabel = Jekyll::VitePressTheme::VersionLabel

  def test_auto_value_matches_case_insensitively
    assert VersionLabel.auto_value?('auto')
    assert VersionLabel.auto_value?('AUTO')
    assert VersionLabel.auto_value?(' auto ')
  end

  def test_auto_value_rejects_other_values
    refute VersionLabel.auto_value?('v1.2.3')
    refute VersionLabel.auto_value?(nil)
    refute VersionLabel.auto_value?('')
  end
end
