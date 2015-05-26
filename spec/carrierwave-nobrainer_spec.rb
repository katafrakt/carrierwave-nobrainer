require_relative 'spec_helper'

RSpec.describe CarrierWave::NoBrainer do
  class Model
    cattr_reader :uploader
    @@uploader = Class.new(CarrierWave::Uploader::Base)
    
    include NoBrainer::Document
    include CarrierWave::NoBrainer

    field :image, type: String
    mount_uploader :image, @@uploader
    mount_uploaders :files, @@uploader
  end

  let(:uploader) { Model.uploader }
  let(:model) { Model.new }

  let(:file1) { File.open(file_path('test.jpeg')) }
  let(:file2) { File.open(file_path('test.txt')) }

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
    model[:image] = 'test.jpeg'
    model.save
    expect(model.image).to be_an_instance_of(uploader)
  end

  it "should set the path to the store dir" do
    expect(File.exists?(file_path('test.jpeg'))).to be_truthy
    model.image = File.open(file_path('test.txt'))

    model.save!
    id = model.id
    model.reload

    expect(model.image.path).to eq(public_path('uploads/test.txt'))
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
    expect(model.image).not_to be_blank
    model.remove_image = true
    model.save
    model.reload
    expect(model.image).to be_blank
  end

  context 'when file is changing' do
    it 'detects the change' do
      m = Model.new
      m.image = file1
      m.save

      path1 = m.image.path
      expect(File.exist?(path1)).to be_truthy

      expect(m.image_changed?).to be_falsey
      m.image = file2
      expect(m.image_changed?).to be_truthy
      m.save

      expect(File.exist?(path1)).to be_falsey
    end

    it 'removes the file' do
      m = Model.create!(image: file2)
      path1 = m.image.path
      expect(File.exist?(path1)).to be_truthy
      m.remove_image!
      expect(File.exist?(path1)).to be_falsey
    end
  end

  context 'when using mount_uploaders' do
    it 'stores files' do
      Model.create!(files: [file1, file2])
      files = Model.last.files
      expect(files.map { |f| f.read }).to eq([file1, file2].map { |f| f.read })
    end
  end

  context 'when using :filename options' do
    let(:filename) { 'stuff.txt' }
    before { Model.mount_uploader :file, nil, :filename => filename }

    it 'mount the file' do
      Model.create!(:file => file1)
      expect(Model.raw.last['file']).to be_nil
      f = Model.first.file
      expect(f.filename).to eq(filename)
      f.retrieve_from_store!(f.filename)
      f.cache!
      expect(File.open(f.path).read).to eq(file1.read)
    end
  end
end
