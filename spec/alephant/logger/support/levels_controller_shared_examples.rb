shared_examples 'a loggable level' do
  it 'returns true' do
    expect(loggable?).to be(true)
  end
end

shared_examples 'a non loggable level' do
  it 'returns false' do
    expect(loggable?).to be(false)
  end
end
