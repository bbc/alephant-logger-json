shared_examples 'a loggable level' do
  it 'returns true' do
    expect(subject).to be(true)
  end
end

shared_examples 'a non loggable level' do
  it 'returns false' do
    expect(subject).to be(false)
  end
end
