shared_examples 'a writeable log' do
  it 'returns true' do
    expect(subject.logs?(message_level)).to be(true)
  end
end

shared_examples 'a non writeable log' do
  it 'returns false' do
    expect(subject.logs?(message_level)).to be(false)
  end
end
