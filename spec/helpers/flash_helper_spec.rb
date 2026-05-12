require 'rails_helper'

RSpec.describe FlashHelper, type: :helper do
  describe "#css_class_for_flash" do
    context "when flash is for alert" do
      it "is red" do
        expect(css_class_for_flash("alert")).to include("bg-red-50 text-red-700 border-red-200")
      end
    end

    context "when flash is not for alert" do
      it "is cyan" do
        expect(css_class_for_flash("notice")).to include("bg-cyan-50 text-cyan-700 border-cyan-200")
      end
    end
  end
end
