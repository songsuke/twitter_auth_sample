require 'rails_helper'

RSpec.describe User, type: :model do
  context 'by twitter' do
    subject { build(:user, :by_twitter) }

    it { is_expected.to_not validate_presence_of(:name) }
    it { is_expected.to_not validate_presence_of(:password) }
    it { is_expected.to validate_presence_of(:email) }
    it { should validate_uniqueness_of(:uid).scoped_to(:provider) }
  end
end
