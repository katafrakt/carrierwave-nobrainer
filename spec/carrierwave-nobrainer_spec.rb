require_relative 'spec_helper'

RSpec.describe CarrierWave::NoBrainer do
    class Model
      cattr_reader :uploader
      @@uploader = Class.new(CarrierWave::Uploader::Base)
      include NoBrainer::Document
      include CarrierWave::NoBrainer

      field :image, type: String
      mount_uploader :image, @@uploader
    end

    let(:uploader) { Model.uploader }
    let(:model) do
      Model.new
    end

    after(:each) do
      model.destroy
    end

  it "should return blank uploader when nothing has been assigned" do
    expect(model.image).to be_blank
  end

  it "should return blank uploader when an empty string has been assigned" do
    model.image = ''
    model.save
    id = model.id
    model = Model.find(id)
    expect(model.image).to be_blank
  end

  it "should retrieve a file from the storage if a value is stored in the database" do
    model.image = 'test.jpeg'
    model.save
    expect(model.image).to be_an_instance_of(uploader)
  end

  it "should set the path to the store dir" do
    model.image = File.open(file_path('test.jpeg'))
    model.save
    id = model.id
    model.reload
    expect(model.image.path).to eq(public_path('uploads/test.jpeg'))
  end

  it "should cache a file" do
    model.image = stub_file('test.jpeg')
    expect(model.image).to be_an_instance_of(uploader)
  end

  it "should copy a file into into the cache directory" do
    model.image = stub_file('test.jpeg')
    expect(model.image.current_path).to match(/^#{public_path('uploads/tmp')}/)
  end

  it "should do nothing when nil is assigned" do
    model.image = nil
    expect(model.image).to be_blank
  end

  it "should do nothing when an empty string is assigned" do
    model.image = ''
    expect(model.image).to be_blank
  end

  it "should do nothing when no file has been assigned" do
    expect(model.save?).to be_truthy
    expect(model.image).to be_blank
  end

  it "should copy the file to the upload directory when a file has been assigned" do
    model.image = stub_file('test.jpeg')
    expect(model.save?).to be_truthy
    expect(model.image).to be_an_instance_of(uploader)
    expect(model.image.current_path).to eq(public_path('uploads/test.jpeg'))
  end

  context 'with validation' do
    class InvalidModel < Model
      validate { errors.add(:base, "BOOM!") }
    end

    let(:model) { InvalidModel.new }

    it "should do nothing when a validation fails" do
      model.image = stub_file('test.jpeg')
      expect(model).not_to be_valid
      model.save rescue NoBrainer::Error::DocumentInvalid
      expect(model).to be_new_record
      expect(model.image).to be_an_instance_of(uploader)
      expect(model.image.current_path).to match(/^#{public_path('uploads/tmp')}/)
    end
  end

  it "should remove the image if remove_image? returns true" do
    model.image = stub_file('test.jpeg')
    model.save
    model.remove_image = true
    model.save
    model.reload
    expect(model.image).to be_blank
  end

end
