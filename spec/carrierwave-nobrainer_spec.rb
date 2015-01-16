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
    model.image = 'test.jpeg'
    model.save
    id = model.id
    model = Model.find(id)
    expect(model.image.path).to eq(public_path('uploads/test.jpeg'))
  end

  it "should cache a file" do
    model.image = stub_file('test.jpeg')
    model.image.should be_an_instance_of(uploader)
  end

  it "should write nothing to the database, to prevent overriden filenames to fail because of unassigned attributes" do
    model[:image].should be_nil
  end

  it "should copy a file into into the cache directory" do
    model.image = stub_file('test.jpeg')
    model.image.current_path.should =~ /^#{public_path('uploads/tmp')}/
  end

  it "should do nothing when nil is assigned" do
    model.image = nil
    model.image.should be_blank
  end

  it "should do nothing when an empty string is assigned" do
    model.image = ''
    model.image.should be_blank
  end

  it "should do nothing when no file has been assigned" do
    model.save.should be_true
    model.image.should be_blank
  end

  it "should copy the file to the upload directory when a file has been assigned" do
    model.image = stub_file('test.jpeg')
    model.save.should be_true
    model.image.should be_an_instance_of(uploader)
    model.image.current_path.should == public_path('uploads/test.jpeg')
  end

  describe 'with validation' do

    before do
      @class.class_eval do
        def validate
          errors.add(:image, 'FAIL!')
        end
      end
      # Turn off raising the exceptions on save
      model.raise_on_save_failure = false
    end

    it "should do nothing when a validation fails" do
      model.image = stub_file('test.jpeg')
      model.should_not be_valid
      model.save
      model.should be_new
      model.image.should be_an_instance_of(uploader)
      model.image.current_path.should =~ /^#{public_path('uploads/tmp')}/
    end
  end

  it "should assign the filename to the database" do
    model.image = stub_file('test.jpeg')
    model.save.should be_true
    model.reload
    model[:image].should == 'test.jpeg'
  end

  it "should remove the image if remove_image? returns true" do
    model.image = stub_file('test.jpeg')
    model.save
    model.remove_image = true
    model.save
    model.reload
    model.image.should be_blank
    model[:image].should == ''
  end

  describe '#save' do

    before do
      @uploader.class_eval do
        def filename
          model.name + File.extname(super)
        end
      end
      model.stub!(:name).and_return('jonas')
    end

    it "should copy the file to the upload directory when a file has been assigned" do
      model.image = stub_file('test.jpeg')
      model.save.should be_true
      model.image.should be_an_instance_of(uploader)
      model.image.current_path.should == public_path('uploads/jonas.jpeg')
    end

    it "should assign an overridden filename to the database" do
      model.image = stub_file('test.jpeg')
      model.save.should be_true
      model.reload
      model[:image].should == 'jonas.jpeg'
    end

  end

end
